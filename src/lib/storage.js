const storageKey = 'thread-wardrobe-v1'

export async function loadWardrobe() {
  try {
    const response = await fetch('/api/state')
    if (response.ok) {
      const data = await response.json()
      if (data?.items?.length) {
        localStorage.setItem(storageKey, JSON.stringify(data))
        return data
      }
    }
  } catch {
    // The browser app can run without the API server.
  }

  try {
    const stored = localStorage.getItem(storageKey)
    return stored ? JSON.parse(stored) : null
  } catch {
    return null
  }
}

export async function saveWardrobe(state) {
  const data = JSON.parse(JSON.stringify(state))
  try {
    localStorage.setItem(storageKey, JSON.stringify(data))
  } catch {
    // Quota or browser storage restrictions should not interrupt outfit editing.
  }

  try {
    await fetch('/api/state', {
      method: 'PUT',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(data),
    })
  } catch {
    // The PostgreSQL API is optional during local-only use.
  }
}