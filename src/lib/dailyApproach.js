const weeklyApproaches = [
  { title: 'Ease into the week', prompt: 'Reach for a familiar favorite and let it set the tone.' },
  { title: 'Stay in one color family', prompt: 'Try nearby shades for a quiet, considered palette.' },
  { title: 'Make one small contrast', prompt: 'Let one unexpected color do the talking.' },
  { title: 'Dress by texture', prompt: 'Pair smooth, soft, and structured pieces.' },
  { title: 'Take a favorite further', prompt: 'Rework a piece you already love in a new way.' },
  { title: 'Add a playful detail', prompt: 'Choose one accessory that feels a little unlike you.' },
  { title: 'Choose room to breathe', prompt: 'Keep it simple, comfortable, and entirely your own.' },
]

export function approachForDate(date) {
  return weeklyApproaches[date.getDay()]
}