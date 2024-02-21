CREATE TABLE IF NOT EXISTS threads
(
    thread_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    description TEXT NULL,
    image_id VARCHAR(255) NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);