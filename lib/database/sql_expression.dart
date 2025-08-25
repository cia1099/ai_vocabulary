import 'package:ai_vocabulary/utils/shortcut.dart' show kMaxAcquaintance;

const insertWord = r'INSERT INTO words (id, word) VALUES (?, ?)';
const insertDefinition = '''
INSERT INTO definitions (word_id, id, part_of_speech, inflection, phonetic_us, phonetic_uk, audio_us, audio_uk, synonyms, antonyms) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING definitions.id
''';
const insertExplanation =
    r'INSERT INTO explanations (word_id, definition_id, explain, subscript) VALUES (?, ?, ?, ?) RETURNING explanations.id';
const insertExample =
    r'INSERT INTO examples (word_id, explanation_id, example) VALUES (?, ?, ?)';
const insertAsset = r'INSERT INTO assets (word_id, filename) VALUES (?, ?)';
// DELETE FROM assets WHERE word_id=?;
// DELETE FROM examples WHERE word_id=?;
// DELETE FROM explanations WHERE word_id=?;
// DELETE FROM definitions WHERE word_id=?;
const isExistWord =
    r'SELECT EXISTS (SELECT 1 FROM words WHERE id = ?) AS exist';
const deleteVocabulary = '''
DELETE FROM words WHERE id=?;
''';

const fetchWordInID = '''
SELECT def.word_id, word, filename AS asset,
def.id AS definition_id, part_of_speech, inflection, 
phonetic_uk, phonetic_us, audio_uk, audio_us, synonyms, antonyms,
subscript, explain, example
FROM definitions def JOIN words ON words.id = def.word_id 
LEFT OUTER JOIN assets ON assets.word_id = def.word_id
JOIN explanations ON explanations.definition_id = def.id
LEFT OUTER JOIN examples ON examples.explanation_id = explanations.id
WHERE def.word_id IN
''';

final avgFib =
    '''
WITH RECURSIVE Fibonacci(id, acquaint, n, a, b) AS (
    SELECT word_id, acquaint, 0, 1, 1 
    FROM acquaintances 
    WHERE last_learned_time IS NOT NULL
    UNION ALL 
    SELECT id, acquaint, n + 1, b, a + b 
    FROM Fibonacci 
    WHERE n + 1 <= acquaint AND acquaint < $kMaxAcquaintance
),
fibCTE AS (
    SELECT id, MAX(a) AS fib 
    FROM Fibonacci 
    GROUP BY id
),
probabilityCTE AS (SELECT 
    word_id, 
    1.0/(? - last_learned_time) / 
    NULLIF((SELECT SUM(1.0/(? - last_learned_time)) 
            FROM acquaintances 
            WHERE last_learned_time IS NOT NULL), 0) AS rate
FROM acquaintances 
WHERE last_learned_time IS NOT NULL AND user_id=?
)
SELECT SUM(p.rate * f.fib) AS avgFib FROM probabilityCTE p
JOIN fibCTE f ON p.word_id = f.id;
''';

const retention = '''
WITH RECURSIVE Fibonacci(id, acquaint, n, a, b) AS (
    SELECT word_id, acquaint, 0, 1, 1 
    FROM acquaintances 
    WHERE acquaint > 0
    UNION ALL 
    SELECT id, acquaint, n + 1, b, a + b 
    FROM Fibonacci 
    WHERE n + 1 <= acquaint
),
fibCTE AS (
    SELECT id, MAX(a) AS fib 
    FROM Fibonacci 
    GROUP BY id
)
SELECT acq.word_id, acq.acquaint, acq.last_learned_time,
    CASE 
        WHEN acq.last_learned_time IS NULL OR acq.acquaint = 0
        THEN 0.0 
        WHEN (? - acq.last_learned_time) / 240.0 / f.fib >= 1.0 
        THEN 1.84 / (POW(LN((? - acq.last_learned_time) / 240.0 / f.fib), 2) + 1.84) 
        ELSE 1.0 
    END AS retention
FROM acquaintances acq
JOIN fibCTE f ON acq.word_id = f.id
ORDER BY retention ASC;
''';

const createDictionary = '''
CREATE TABLE words (
        id INTEGER NOT NULL, 
        word VARCHAR, 
        PRIMARY KEY (id), 
        UNIQUE (word)
);
CREATE TABLE definitions (
        id INTEGER NOT NULL, 
        word_id INTEGER NOT NULL, 
        part_of_speech VARCHAR, 
        inflection VARCHAR, 
        phonetic_us VARCHAR, 
        phonetic_uk VARCHAR, 
        audio_us VARCHAR, 
        audio_uk VARCHAR, 
        synonyms VARCHAR, 
        antonyms VARCHAR, 
        PRIMARY KEY (id), 
        CONSTRAINT definition_unique UNIQUE (word_id, id), 
        FOREIGN KEY(word_id) REFERENCES words (id) ON DELETE CASCADE
);
CREATE TABLE explanations (
        id INTEGER NOT NULL, 
        word_id INTEGER NOT NULL, 
        definition_id INTEGER NOT NULL, 
        explain VARCHAR NOT NULL, 
        subscript VARCHAR, 
        PRIMARY KEY (id), 
        CONSTRAINT explanation_unique UNIQUE (definition_id, id), 
        FOREIGN KEY(word_id) REFERENCES words (id) ON DELETE CASCADE, 
        FOREIGN KEY(definition_id) REFERENCES definitions (id) ON DELETE CASCADE
);
CREATE TABLE examples (
        id INTEGER NOT NULL, 
        word_id INTEGER NOT NULL, 
        explanation_id INTEGER NOT NULL, 
        example VARCHAR, 
        PRIMARY KEY (id), 
        CONSTRAINT example_unique UNIQUE (explanation_id, id), 
        FOREIGN KEY(word_id) REFERENCES words (id) ON DELETE CASCADE, 
        FOREIGN KEY(explanation_id) REFERENCES explanations (id) ON DELETE CASCADE
);
CREATE TABLE assets (
        id INTEGER NOT NULL, 
        word_id INTEGER NOT NULL, 
        filename VARCHAR NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT word_unique UNIQUE (word_id, id), 
        FOREIGN KEY(word_id) REFERENCES words (id) ON DELETE CASCADE
);
CREATE TABLE users (
        id TEXT NOT NULL, 
        update_at DATETIME, 
        PRIMARY KEY (id)
);
CREATE TABLE acquaintances (
        word_id INTEGER NOT NULL, 
        user_id TEXT, 
        acquaint INTEGER NOT NULL DEFAULT 0, 
        last_learned_time INTEGER, 
        PRIMARY KEY (word_id, user_id),
        FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE,
        CONSTRAINT acquaintance_unique UNIQUE (word_id, user_id)
);
CREATE TABLE text_messages (
        time_stamp INTEGER NOT NULL, 
        word_id INTEGER NOT NULL, 
        user_id TEXT, 
        owner_id TEXT NOT NULL,
        content VARCHAR NOT NULL,  
        patterns VARCHAR NOT NULL DEFAULT '',
        PRIMARY KEY (time_stamp, owner_id),
        FOREIGN KEY(owner_id) REFERENCES users (id) ON DELETE CASCADE
);
CREATE TABLE collections (
        id INTEGER NOT NULL, 
        name VARCHAR NOT NULL, 
        user_id TEXT,
        "index" INTEGER NOT NULL, 
        icon INTEGER, 
        color INTEGER, 
        PRIMARY KEY (id, user_id),
        FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE,
        CONSTRAINT collection_key UNIQUE (id, user_id),
        CONSTRAINT collection_name UNIQUE (name, user_id)
);
CREATE TABLE collect_words (
        user_id TEXT,
        word_id INTEGER NOT NULL,
        collection_id INTEGER DEFAULT 0,
        PRIMARY KEY (word_id, collection_id, user_id),
        FOREIGN KEY(collection_id, user_id) REFERENCES collections (id, user_id) ON DELETE CASCADE,
        CONSTRAINT collect_word_unique UNIQUE (user_id, word_id, collection_id)
);
CREATE TABLE history_searches (
        word_id INTEGER NOT NULL,
        time_stamp INTEGER NOT NULL,
        PRIMARY KEY (word_id)
);
CREATE TABLE punch_days (
        date INTEGER NOT NULL,
        user_id TEXT,
        study_minute INTEGER NOT NULL DEFAULT 0,
        study_word_ids VARCHAR NOT NULL DEFAULT '',
        punch_time INTEGER,
        PRIMARY KEY (date, user_id)
);
CREATE INDEX "IX_definitions_word_id" ON definitions (word_id);
CREATE INDEX "IX_explanations_definition_id" ON explanations (definition_id);
CREATE INDEX "IX_examples_explanation_id" ON examples (explanation_id);
CREATE INDEX "IX_explanations_word_id" ON explanations (word_id);
CREATE INDEX "IX_examples_word_id" ON examples (word_id);
CREATE INDEX "IX_assets_word_id" ON assets (word_id);
CREATE INDEX "IX_text_message" ON text_messages (owner_id, word_id);
CREATE INDEX "IX_collect_word" ON collect_words (user_id, word_id);
CREATE INDEX "IX_collect_word_in_mark" ON collect_words (user_id, collection_id);
''';
