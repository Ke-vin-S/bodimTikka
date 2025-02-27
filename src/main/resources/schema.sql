CREATE TABLE "user" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,      -- nullable for unregistered users
    password VARCHAR(255)           -- nullable
);

CREATE TABLE room (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE user_in_room (
    id SERIAL PRIMARY KEY,
    user_id INT,                         -- Nullable for unregistered users
    room_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,          -- Display name for the room
    is_still_a_member BOOLEAN DEFAULT TRUE,
    is_admin BOOLEAN DEFAULT FALSE,
    is_registered BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES "user"(id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES room(id) ON DELETE CASCADE,
    UNIQUE (user_id, room_id)       -- Ensures a user can only be added once to a room
);

CREATE TABLE payment (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    description TEXT,
    is_repayment BOOLEAN DEFAULT FALSE,
    payment_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES room(id) ON DELETE CASCADE
);

CREATE INDEX idx_payment_timestamp ON payment(payment_timestamp DESC);

CREATE TABLE payment_record (
    id SERIAL PRIMARY KEY,
    -- from_id < to_id
    from_user_id INT NOT NULL,
    to_user_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    payment_id UUID NOT NULL,
    is_credit BOOLEAN NOT NULL,  -- Replaces 'direction' for better clarity
    FOREIGN KEY (from_user_id) REFERENCES "user"(id) ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES "user"(id) ON DELETE CASCADE,
    FOREIGN KEY (payment_id) REFERENCES payment(payment_id) ON DELETE CASCADE,
    UNIQUE (payment_id, from_user_id, to_user_id)
);

-- FIXME
--from user -> to user !is_credit
--to user -> from user is_credit
--be careful when querying

--SELECT user_1, user_2,
--       SUM(CASE WHEN direction = 'user_1 → user_2' THEN amount ELSE -amount END) AS net_balance
--FROM transactions
--WHERE user_1 = ? AND user_2 = ?
--GROUP BY user_1, user_2;


CREATE INDEX idx_from_user ON payment_record (from_user_id);
CREATE INDEX idx_to_user ON payment_record (to_user_id);
CREATE INDEX idx_room ON payment (room_id);
CREATE INDEX idx_payment_users ON payment_record (from_user_id, to_user_id);

CREATE VIEW room_payment_log AS
SELECT
    p.payment_id,
    p.room_id,
    p.amount AS total_amount,
    p.description,
    p.is_repayment,
    p.payment_timestamp,
    pr.from_user_id,
    pr.to_user_id,
    pr.amount AS user_amount,
    pr.is_credit
FROM payment p
LEFT JOIN payment_record pr ON p.payment_id = pr.payment_id;

-- return balances to be paid
CREATE MATERIALIZED VIEW room_pair_balances_to_pay AS
WITH pair_balance AS (
    SELECT
        u1.room_id,
        LEAST(pr.from_user_id, pr.to_user_id) AS from_user,
        GREATEST(pr.from_user_id, pr.to_user_id) AS to_user,
        SUM(CASE
            WHEN pr.is_credit THEN pr.amount
            ELSE -pr.amount
        END) AS balance
    FROM payment_record pr
    JOIN user_in_room u1 ON pr.from_user_id = u1.user_id
    JOIN user_in_room u2 ON pr.to_user_id = u2.user_id
    WHERE u1.room_id = u2.room_id
    GROUP BY u1.room_id, from_user, to_user
)
SELECT * FROM pair_balance;

--CREATE INDEX idx_room_pair_balances_room ON room_pair_balances_to_pay(room_id);
--CREATE INDEX idx_room_pair_balances_users ON room_pair_balances_to_pay(from_user, to_user);
