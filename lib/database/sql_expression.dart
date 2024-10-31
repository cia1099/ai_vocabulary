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
        chinese VARCHAR, 
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
''';

const insertWord = r'INSERT INTO words (id, word) VALUES (?, ?)';
const insertDefinition = '''
INSERT INTO definitions (word_id, part_of_speech, inflection, alphabet_us, alphabet_uk, audio_us, audio_uk, chinese) VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING definitions.id
''';
const insertExplanation =
    r'INSERT INTO explanations (word_id, definition_id, explain, subscript) VALUES (?, ?, ?, ?) RETURNING explanations.id';
const insertExample =
    r'INSERT INTO examples (word_id, explanation_id, example) VALUES (?, ?, ?)';
const insertAsset = r'INSERT INTO assets (word_id, filename) VALUES (?, ?)';
