const emptyState = () => ({ items: [], looks: {}, settings: { weekStarts: 0, showLookNames: true, accent: 'forest' } })
const copy = (value) => value == null ? null : structuredClone(value)

export function createMemoryStore(initialState = emptyState()) {
  let current = copy(initialState)
  return {
    async get() { return copy(current) },
    async set(value) { current = copy(value); return copy(current) },
  }
}

export function createPostgresStore(pool) {
  return {
    async initialize() {
      await pool.query(`CREATE TABLE IF NOT EXISTS wardrobe_state (
        singleton_id SMALLINT PRIMARY KEY DEFAULT 1 CHECK (singleton_id = 1),
        payload JSONB NOT NULL,
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )`)
    },
    async get() {
      const result = await pool.query('SELECT payload FROM wardrobe_state WHERE singleton_id = 1')
      return result.rows[0]?.payload ?? null
    },
    async set(value) {
      const result = await pool.query(
        `INSERT INTO wardrobe_state (singleton_id, payload, updated_at)
         VALUES (1, $1::jsonb, NOW())
         ON CONFLICT (singleton_id) DO UPDATE SET payload = EXCLUDED.payload, updated_at = NOW()
         RETURNING payload`,
        [JSON.stringify(value)],
      )
      return result.rows[0].payload
    },
  }
}
