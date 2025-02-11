const insertWord = r'INSERT INTO words (id, word) VALUES (?, ?)';
const insertDefinition = '''
INSERT INTO definitions (word_id, part_of_speech, inflection, alphabet_us, alphabet_uk, audio_us, audio_uk, translate) VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING definitions.id
''';
const insertExplanation =
    r'INSERT INTO explanations (word_id, definition_id, explain, subscript) VALUES (?, ?, ?, ?) RETURNING explanations.id';
const insertExample =
    r'INSERT INTO examples (word_id, explanation_id, example) VALUES (?, ?, ?)';
const insertAsset = r'INSERT INTO assets (word_id, filename) VALUES (?, ?)';

const insertAcquaintance =
    r'INSERT INTO acquaintances (word_id, user_id) VALUES (?, ?)';

const insertTextMessage =
    r'INSERT INTO text_messages (time_stamp, content, word_id, patterns, user_id) VALUES (?, ?, ?, ?, ?)';

const deleteVocabulary = '''
DELETE FROM assets WHERE word_id=?;
DELETE FROM examples WHERE word_id=?;
DELETE FROM explanations WHERE word_id=?;
DELETE FROM definitions WHERE word_id=?;
DELETE FROM words WHERE id=?;
''';

const fetchWordInID = '''
SELECT words.id, words.word, assets.filename, 
acquaintances.acquaint, acquaintances.last_learned_time, 
definitions.part_of_speech, definitions.inflection, definitions.alphabet_uk, definitions.alphabet_us, 
definitions.audio_uk, definitions.audio_us, definitions.translate, 
explanations.subscript, explanations.explain, examples.example 
FROM words LEFT OUTER JOIN assets ON assets.word_id = words.id 
JOIN acquaintances ON words.id = acquaintances.word_id 
JOIN definitions ON words.id = definitions.word_id 
JOIN explanations ON explanations.definition_id = definitions.id 
LEFT OUTER JOIN examples ON examples.explanation_id = explanations.id 
WHERE words.id IN
''';

const avgFib = '''
WITH RECURSIVE Fibonacci(id, acquaint, n, a, b) AS (
    SELECT word_id, acquaint, 0, 1, 1 
    FROM acquaintances 
    WHERE last_learned_time IS NOT NULL
    UNION ALL 
    SELECT id, acquaint, n + 1, b, a + b 
    FROM Fibonacci 
    WHERE n + 1 <= acquaint
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
WHERE last_learned_time IS NOT NULL
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
        alphabet_us VARCHAR, 
        alphabet_uk VARCHAR, 
        audio_us VARCHAR, 
        audio_uk VARCHAR, 
        translate VARCHAR, 
        PRIMARY KEY (id), 
        CONSTRAINT definition_unique UNIQUE (word_id, id), 
        FOREIGN KEY(word_id) REFERENCES words (id)
);
CREATE TABLE explanations (
        id INTEGER NOT NULL, 
        word_id INTEGER NOT NULL, 
        definition_id INTEGER NOT NULL, 
        explain VARCHAR NOT NULL, 
        subscript VARCHAR, 
        PRIMARY KEY (id), 
        CONSTRAINT explanation_unique UNIQUE (definition_id, id), 
        FOREIGN KEY(word_id) REFERENCES words (id), 
        FOREIGN KEY(definition_id) REFERENCES definitions (id)
);
CREATE TABLE examples (
        id INTEGER NOT NULL, 
        word_id INTEGER NOT NULL, 
        explanation_id INTEGER NOT NULL, 
        example VARCHAR, 
        PRIMARY KEY (id), 
        CONSTRAINT example_unique UNIQUE (explanation_id, id), 
        FOREIGN KEY(word_id) REFERENCES words (id), 
        FOREIGN KEY(explanation_id) REFERENCES explanations (id)
);
CREATE TABLE assets (
        id INTEGER NOT NULL, 
        word_id INTEGER NOT NULL, 
        filename VARCHAR NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT word_unique UNIQUE (word_id, id), 
        FOREIGN KEY(word_id) REFERENCES words (id)
);
CREATE TABLE users (
        id UUID NOT NULL, 
        email VARCHAR NOT NULL, 
        PRIMARY KEY (id)
);
CREATE TABLE acquaintances (
        word_id INTEGER NOT NULL, 
        user_id UUID, 
        acquaint INTEGER NOT NULL DEFAULT 0, 
        last_learned_time INTEGER, 
        PRIMARY KEY (word_id), 
        FOREIGN KEY(word_id) REFERENCES words (id),
        FOREIGN KEY(user_id) REFERENCES users (id)
);
CREATE TABLE text_messages (
        time_stamp INTEGER NOT NULL, 
        word_id INTEGER NOT NULL, 
        user_id UUID, 
        content VARCHAR NOT NULL,  
        patterns VARCHAR NOT NULL DEFAULT '',  
        PRIMARY KEY (time_stamp), 
        FOREIGN KEY(word_id) REFERENCES words (id), 
        FOREIGN KEY(user_id) REFERENCES users (id)
);
CREATE TABLE collections (
        id INTEGER NOT NULL, 
        "index" INTEGER NOT NULL, 
        name VARCHAR NOT NULL, 
        icon INTEGER, 
        color INTEGER, 
        PRIMARY KEY (id), 
        UNIQUE (name)
);
CREATE TABLE collect_words (
        id INTEGER NOT NULL, 
        word_id INTEGER NOT NULL, 
        mark VARCHAR NOT NULL DEFAULT 'uncategorized',
        PRIMARY KEY (id), 
        CONSTRAINT collection_unique UNIQUE (word_id, mark), 
        FOREIGN KEY(word_id) REFERENCES words (id), 
        FOREIGN KEY(mark) REFERENCES collections (name)
);
''';
