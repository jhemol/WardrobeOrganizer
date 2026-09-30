export function suggestOutfits(items, occasion = 'Everyday') {
  const tops = items.filter((item) => item.category === 'Top')
  const bottoms = items.filter((item) => item.category === 'Bottom')
  const layers = items.filter((item) => item.category === 'Layer')
  const shoes = items.filter((item) => item.category === 'Shoes')
  const dresses = items.filter((item) => item.category === 'Dress')
  const suggestions = []
  for (const [index, dress] of dresses.entries()) {
    const shoe = shoes.length ? shoes[index % shoes.length] : null
    suggestions.push({
      id: `dress-${dress.id}`,
      title: occasion === 'Evening' ? 'A softer kind of evening' : 'One piece, already a whole look',
      items: [dress.id, ...(shoe ? [shoe.id] : [])],
      note: `Built around your ${dress.color} ${dress.category.toLowerCase()}.`,
    })
  }

  for (const [index, top] of tops.entries()) {
    const bottom = bottoms.length ? bottoms[index % bottoms.length] : null
    if (!bottom) continue
    const layer = layers.length ? layers[index % layers.length] : null
    const shoe = shoes.length ? shoes[index % shoes.length] : null
    const outfit = [top.id, bottom.id, ...(layer ? [layer.id] : []), ...(shoe ? [shoe.id] : [])]
    suggestions.push({
      id: `pair-${top.id}-${bottom.id}`,
      title: occasion === 'Work' ? 'Considered, not complicated' : occasion === 'Weekend' ? 'An easy day uniform' : 'A familiar favorite, remixed',
      items: outfit,
      note: `A ${top.color} and ${bottom.color} pairing from your closet.`,
    })
  }

  return suggestions.slice(0, 6)
}

