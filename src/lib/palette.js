const colorMap = {
  black: '#252525',
  white: '#f4f1e9',
  cream: '#e8dfce',
  navy: '#27374d',
  blue: '#6487a5',
  denim: '#53718c',
  red: '#b94d43',
  burgundy: '#713a49',
  green: '#6f8069',
  olive: '#858252',
  yellow: '#d3aa57',
  pink: '#d49a9d',
  brown: '#84634e',
  gray: '#969995',
}

function hexToRgb(hex) {
  const normalized = hex.replace('#', '')
  const value = normalized.length === 3
    ? normalized.split('').map((part) => part + part).join('')
    : normalized

  if (!/^[\da-f]{6}$/i.test(value)) return null
  return [0, 2, 4].map((index) => Number.parseInt(value.slice(index, index + 2), 16))
}

function distance(left, right) {
  const a = hexToRgb(colorMap[left.toLowerCase()] ?? left)
  const b = hexToRgb(colorMap[right.toLowerCase()] ?? right)
  if (!a || !b) return 0
  return Math.sqrt(a.reduce((total, channel, index) => total + (channel - b[index]) ** 2, 0))
}

export function coordinatePalette(colors) {
  const uniqueColors = [...new Set(colors.filter(Boolean).map((color) => color.toLowerCase()))]
  const averageDistance = uniqueColors.length < 2
    ? 0
    : uniqueColors.reduce((total, color, index) => (
      total + uniqueColors.slice(index + 1).reduce((sum, other) => sum + distance(color, other), 0)
    ), 0) / (uniqueColors.length * (uniqueColors.length - 1) / 2)

  return {
    colors: uniqueColors,
    score: Math.max(0, Math.min(100, Math.round(100 - averageDistance / 4.42))),
    label: uniqueColors.length < 2 ? 'Add a second color' : averageDistance > 270 ? 'High contrast' : 'In harmony',
  }
}