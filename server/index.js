import 'dotenv/config'
import express from 'express'
import { Pool } from 'pg'
import { pathToFileURL } from 'node:url'
import { createMemoryStore, createPostgresStore } from './stateStore.js'

export function createApp(store) {
  const app = express()
  app.use(express.json({ limit: '1mb' }))
  app.get('/api/health', (_request, response) => response.json({ ok: true }))
  app.get('/api/state', async (_request, response) => {
    response.json(await store.get())
  })
  app.put('/api/state', async (request, response) => {
    const value = request.body
    if (!value || !Array.isArray(value.items) || typeof value.looks !== 'object' || value.looks === null || typeof value.settings !== 'object' || value.settings === null) {
      return response.status(400).json({ error: 'State must include items, looks, and settings.' })
    }
    if (value.items.length > 500 || Object.keys(value.looks).length > 500) {
      return response.status(413).json({ error: 'Wardrobe state exceeds the supported size.' })
    }
    response.json(await store.set(value))
  })
  return app
}

async function start() {
  const pool = process.env.DATABASE_URL
    ? new Pool({ connectionString: process.env.DATABASE_URL, ssl: process.env.PGSSLMODE === 'require' ? { rejectUnauthorized: false } : undefined })
    : null
  const store = pool ? createPostgresStore(pool) : createMemoryStore()
  if (pool) await store.initialize()
  const port = Number(process.env.API_PORT || 5174)
  const server = createApp(store).listen(port, () => {
    console.log(`Wardrobe API listening on http://localhost:${port}${pool ? ' (PostgreSQL)' : ' (memory store)'}`)
  })
  const shutdown = async () => {
    server.close()
    if (pool) await pool.end()
  }
  process.on('SIGINT', shutdown)
  process.on('SIGTERM', shutdown)
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  start().catch((error) => { console.error(error); process.exitCode = 1 })
}
