<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { IonApp, IonIcon } from '@ionic/vue'
import { addOutline, arrowBackOutline, arrowForwardOutline, calendarClearOutline, checkmarkCircle, closeOutline, colorPaletteOutline, helpCircleOutline, shirtOutline, sparklesOutline, settingsOutline, sunnyOutline, trashOutline } from 'ionicons/icons'
import { coordinatePalette } from './lib/palette.js'
import { approachForDate } from './lib/dailyApproach.js'
import { suggestOutfits } from './lib/styling.js'
import { loadWardrobe, saveWardrobe } from './lib/storage.js'

const today = new Date()
const keyFor = (date) => `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
const parseDate = (key) => { const [year, month, day] = key.split('-').map(Number); return new Date(year, month - 1, day) }
const images = {
  cream: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=700&q=85',
  olive: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=700&q=85',
  denim: 'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=700&q=85',
  burgundy: 'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?auto=format&fit=crop&w=700&q=85',
  navy: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?auto=format&fit=crop&w=700&q=85',
  brown: 'https://images.unsplash.com/photo-1531310197839-ccf54634509e?auto=format&fit=crop&w=700&q=85',
  red: 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=700&q=85',
  white: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=700&q=85',
}
const starterItems = [
  ['top1', 'Linen overshirt', 'Top', 'cream', '#d9cdb8'], ['top2', 'Ribbed knit tee', 'Top', 'olive', '#77795a'],
  ['bottom1', 'Relaxed straight denim', 'Bottom', 'denim', '#617c91'], ['dress1', 'Sunday slip dress', 'Dress', 'burgundy', '#794b54'],
  ['layer1', 'Soft wool cardigan', 'Layer', 'navy', '#34475b'], ['shoe1', 'Everyday loafers', 'Shoes', 'brown', '#805c47'],
  ['bag1', 'Market tote', 'Accessory', 'red', '#ac5b4c'], ['shoe2', 'Canvas sneakers', 'Shoes', 'white', '#e4e1d8'],
].map(([id, name, category, color, colorHex]) => ({ id, name, category, color, colorHex, image: images[color], season: 'All season' }))
const todayKey = keyFor(today)
const sampleLooks = {}
for (const offset of [0, 2, 4, 6, 8]) {
  const date = new Date(today.getFullYear(), today.getMonth(), today.getDate() + offset)
  sampleLooks[keyFor(date)] = { title: ['Easy layers', 'Soft neutrals', 'Color study', 'Weekend uniform', 'Blue hour'][offset / 2], note: offset === 0 ? 'A little texture, a lot of ease.' : '', items: date.getDay() === 0 ? ['dress1', 'shoe1'] : ['top1', 'bottom1', 'layer1', 'shoe1'] }
}
const state = reactive({ items: structuredClone(starterItems), looks: sampleLooks, settings: { weekStarts: 0, showLookNames: true, accent: 'forest' } })
const month = ref(new Date(today.getFullYear(), today.getMonth(), 1))
const selected = ref(todayKey)
const page = ref('Calendar')
const modal = ref('')
const status = ref('Saved locally')
const tourOpen = ref(false)
const tourIndex = ref(0)
const lookForm = reactive({ title: '', note: '', items: [] })
const itemForm = reactive({ name: '', category: 'Top', color: 'blue', colorHex: '#6487a5', image: '', season: 'All season' })
const filter = reactive({ category: 'All', search: '' })
const styleOccasion = ref('Everyday')
const ready = ref(false)
let saveTimer

const monthLabel = computed(() => new Intl.DateTimeFormat('en', { month: 'long', year: 'numeric' }).format(month.value))
const dateLabel = computed(() => new Intl.DateTimeFormat('en', { weekday: 'long', month: 'long', day: 'numeric' }).format(parseDate(selected.value)))
const selectedLook = computed(() => state.looks[selected.value])
const dailyApproach = computed(() => approachForDate(parseDate(selected.value)))
const outfitItems = computed(() => (selectedLook.value?.items ?? []).map((id) => state.items.find((item) => item.id === id)).filter(Boolean))
const previewItems = computed(() => lookForm.items.map((id) => state.items.find((item) => item.id === id)).filter(Boolean))
const previewPalette = computed(() => coordinatePalette(previewItems.value.map((item) => item.color)))
const palette = computed(() => coordinatePalette(outfitItems.value.map((item) => item.color)))
const cells = computed(() => {
  const first = new Date(month.value.getFullYear(), month.value.getMonth(), 1)
  const offset = (first.getDay() - state.settings.weekStarts + 7) % 7
  const count = new Date(month.value.getFullYear(), month.value.getMonth() + 1, 0).getDate()
  const total = Math.ceil((offset + count) / 7) * 7
  return Array.from({ length: total }, (_, index) => {
    const date = new Date(month.value.getFullYear(), month.value.getMonth(), index - offset + 1)
    return { date, key: keyFor(date), current: date.getMonth() === month.value.getMonth() }
  })
})
const weekdays = computed(() => { const all = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']; return [...all.slice(state.settings.weekStarts), ...all.slice(0, state.settings.weekStarts)] })
const categories = ['All', 'Top', 'Bottom', 'Dress', 'Layer', 'Shoes', 'Accessory']
const stylingIdeas = computed(() => suggestOutfits(state.items, styleOccasion.value))
const tourSteps = [
  {
    eyebrow: 'A WARDROBE THAT WORKS FOR YOU',
    title: 'Start with what you already own.',
    description: 'Bring your pieces into one digital closet. Add a name, category, color, season, and a photo so your wardrobe is easy to browse.',
    image: images.cream,
    imageAlt: 'A neutral wardrobe piece',
    action: 'Explore your closet',
    page: 'Closet',
  },
  {
    eyebrow: 'A STYLIST THAT STARTS WITH YOUR CLOSET',
    title: 'Find a new way to wear what you own.',
    description: 'Browse outfit pairings built from the pieces already in your closet. Choose an occasion to shift the suggestions, then make any idea your own.',
    image: images.olive,
    imageAlt: 'A wardrobe styling idea',
    action: 'Explore style ideas',
    page: 'Style ideas',
  },
  {
    eyebrow: 'YOUR OUTFIT, YOUR CANVAS',
    title: 'Build a look piece by piece.',
    description: 'Choose garments, give the outfit a name, and keep a note about the mood or occasion. See its colors come together as you select.',
    image: images.denim,
    imageAlt: 'Everyday blue denim',
    action: 'Open outfit canvas',
    page: 'Calendar',
    canvas: true,
  },
  {
    eyebrow: 'A LITTLE PLAN, A LITTLE FREEDOM',
    title: 'Give each day its own approach.',
    description: 'Place an OOTD on any date, move between months, choose when your week begins, and keep the looks you want to remember.',
    image: images.cream,
    imageAlt: 'A softly layered outfit',
    action: 'Open calendar settings',
    page: 'Calendar',
    settings: true,
  },
  {
    eyebrow: 'NOTICE YOUR COLOR RHYTHM',
    title: 'See the palette take shape.',
    description: 'Color notes gather the colors in your closet, while each saved outfit gets a harmony score to help you experiment.',
    image: images.red,
    imageAlt: 'A burgundy outfit inspiration',
    action: 'Explore color notes',
    page: 'Color notes',
  },
]
const closetItems = computed(() => state.items.filter((item) => (filter.category === 'All' || item.category === filter.category) && item.name.toLowerCase().includes(filter.search.toLowerCase())))
const heroImage = computed(() => outfitItems.value.find((item) => item.category === 'Dress')?.image ?? outfitItems.value.find((item) => item.category === 'Top')?.image)

watch(state, () => {
  if (!ready.value) return
  status.value = 'Saving'
  clearTimeout(saveTimer)
  saveTimer = setTimeout(async () => { await saveWardrobe(state); status.value = 'Saved locally' }, 350)
}, { deep: true })
onMounted(async () => {
  const saved = await loadWardrobe()
  if (saved?.items?.length) { state.items = saved.items; state.looks = saved.looks ?? {}; state.settings = { ...state.settings, ...saved.settings } }
  ready.value = true
  if (localStorage.getItem('thread-walkthrough-complete') !== 'yes') tourOpen.value = true
})

function changeMonth(amount) { month.value = new Date(month.value.getFullYear(), month.value.getMonth() + amount, 1) }
function openLook(date = selected.value) {
  selected.value = date
  const look = state.looks[date]
  lookForm.title = look?.title ?? ''; lookForm.note = look?.note ?? ''; lookForm.items = [...(look?.items ?? [])]
  modal.value = 'look'
}
function toggleItem(id) { const at = lookForm.items.indexOf(id); at < 0 ? lookForm.items.push(id) : lookForm.items.splice(at, 1) }
function saveLook() {
  if (lookForm.items.length) state.looks[selected.value] = { title: lookForm.title.trim() || 'A new look', note: lookForm.note.trim(), items: [...lookForm.items] }
  else delete state.looks[selected.value]
  modal.value = ''
}
function deleteLook() { delete state.looks[selected.value]; modal.value = '' }
function addItem() {
  if (!itemForm.name.trim()) return
  state.items.unshift({ ...itemForm, id: `item-${Date.now()}`, image: itemForm.image || images[itemForm.color] || images.white })
  Object.assign(itemForm, { name: '', category: 'Top', color: 'blue', colorHex: '#6487a5', image: '', season: 'All season' })
  modal.value = ''
}
function removeItem(id) { state.items = state.items.filter((item) => item.id !== id); Object.values(state.looks).forEach((look) => { look.items = look.items.filter((itemId) => itemId !== id) }) }
function saveStylingIdea(idea) {
  selected.value = todayKey
  state.looks[todayKey] = { title: idea.title, note: idea.note, items: [...idea.items] }
  page.value = 'Calendar'
}
function finishTour() {
  localStorage.setItem('thread-walkthrough-complete', 'yes')
  tourOpen.value = false
}
function continueTour() {
  if (tourIndex.value < tourSteps.length - 1) tourIndex.value += 1
  else {
    page.value = tourSteps[tourIndex.value].page
    finishTour()
  }
}
function openTour() { tourIndex.value = 0; tourOpen.value = true }
function visitTourFeature() {
  const step = tourSteps[tourIndex.value]
  page.value = step.page
  if (step.settings) modal.value = 'settings'
  if (step.canvas) openLook()
  finishTour()
}
</script>

<template>
  <IonApp>
    <div class="app-shell" :data-accent="state.settings.accent">
      <aside class="sidebar">
        <a class="brand" href="#calendar" @click.prevent="page = 'Calendar'"><span class="brand-mark"><IonIcon :icon="sparklesOutline" /></span>thread<span class="brand-period">.</span></a>
        <div class="side-label">YOUR SPACE</div>
        <nav class="main-nav" aria-label="Main navigation">
          <button :class="{ active: page === 'Calendar' }" @click="page = 'Calendar'"><IonIcon :icon="calendarClearOutline" />Calendar</button>
          <button :class="{ active: page === 'Closet' }" @click="page = 'Closet'"><IonIcon :icon="shirtOutline" />My closet <span class="nav-count">{{ state.items.length }}</span></button>
          <button :class="{ active: page === 'Style ideas' }" @click="page = 'Style ideas'"><IonIcon :icon="sparklesOutline" />Style ideas</button>
          <button :class="{ active: page === 'Color notes' }" @click="page = 'Color notes'"><IonIcon :icon="colorPaletteOutline" />Color notes</button>
        </nav>
        <div class="sidebar-bottom"><div class="mini-weather"><IonIcon :icon="sunnyOutline" /><div><strong>Today feels like linen</strong><span>26° · Mostly sunny</span></div></div><button class="profile-button"><span class="avatar">M</span><span><strong>Morgan Lee</strong><small>Personal wardrobe</small></span></button></div>
      </aside>
      <main class="main-content">
        <header class="topbar"><div class="breadcrumb">My space <span>/</span> <strong>{{ page }}</strong></div><div class="top-actions"><span class="save-indicator"><i></i>{{ status }}</span><button class="icon-button" aria-label="Walkthrough" title="Walkthrough" @click="openTour()"><IonIcon :icon="helpCircleOutline" /></button><button class="icon-button" aria-label="Calendar settings" @click="modal = 'settings'"><IonIcon :icon="settingsOutline" /></button></div></header>

        <section v-if="page === 'Calendar'" class="page-wrap">
          <div class="page-heading"><div><p class="eyebrow">A little more intention, every day</p><h1>Outfit calendar</h1><p class="heading-note">Plan a week of getting dressed like yourself.</p></div><button class="primary-button" @click="openLook()"><IonIcon :icon="addOutline" />Plan an outfit</button></div>
          <div class="planner-grid">
            <section class="calendar-panel" aria-label="Outfit calendar">
              <div class="calendar-toolbar"><div class="month-switch"><h2>{{ monthLabel }}</h2><button class="icon-button" aria-label="Previous month" @click="changeMonth(-1)"><IonIcon :icon="arrowBackOutline" /></button><button class="icon-button" aria-label="Next month" @click="changeMonth(1)"><IonIcon :icon="arrowForwardOutline" /></button></div><button class="today-button" @click="month = new Date(today.getFullYear(), today.getMonth(), 1); selected = todayKey">Today</button></div>
              <div class="calendar-grid" :class="{ compact: !state.settings.showLookNames }"><div v-for="day in weekdays" :key="day" class="weekday-label">{{ day }}</div><button v-for="cell in cells" :key="cell.key" class="day-cell" :class="{ muted: !cell.current, selected: selected === cell.key, 'is-today': cell.key === todayKey, 'has-look': state.looks[cell.key] }" @click="selected = cell.key"><span class="day-number">{{ cell.date.getDate() }}</span><span v-if="state.looks[cell.key] && state.settings.showLookNames" class="look-caption">{{ state.looks[cell.key].title }}</span><span v-if="state.looks[cell.key]" class="mini-palette"><i v-for="id in state.looks[cell.key].items.slice(0, 4)" :key="id" :style="{ backgroundColor: state.items.find((item) => item.id === id)?.colorHex ?? '#ddd' }"></i></span><span v-else-if="cell.current" class="empty-day">+</span></button></div>
              <div class="calendar-legend"><span><i class="legend-dot planned"></i>Planned look</span><span><i class="legend-dot today-dot"></i>Today</span><button @click="modal = 'settings'"><IonIcon :icon="settingsOutline" />Customize calendar</button></div>
            </section>
            <aside class="day-panel"><div class="day-panel-header"><div><p class="eyebrow">{{ selected === todayKey ? 'TODAY, YOUR WAY' : 'YOUR DAY' }}</p><h2>{{ dateLabel }}</h2></div><button class="icon-button" aria-label="Plan outfit" @click="openLook()"><IonIcon :icon="addOutline" /></button></div><div class="daily-intention"><span class="intention-mark"><IonIcon :icon="sparklesOutline" /></span><div><small>TODAY'S INTENTION</small><strong>{{ dailyApproach.title }}</strong><p>{{ dailyApproach.prompt }}</p></div></div>
              <template v-if="selectedLook && outfitItems.length"><div class="outfit-hero"><img :src="heroImage" :alt="selectedLook.title" /><div class="image-shade"></div><span class="hero-tag">LOOK OF THE DAY</span><div class="hero-copy"><p>THE PLAN</p><h3>{{ selectedLook.title }}</h3><span>Ready when you are</span></div><button class="hero-edit" aria-label="Edit outfit" @click="openLook()">···</button></div>
                <div class="palette-block"><div class="section-line"><h3>Color story</h3><span>{{ palette.score }}% together</span></div><div class="palette-swatches"><i v-for="item in outfitItems.slice(0, 5)" :key="item.id" class="palette-chip" :style="{ backgroundColor: item.colorHex }" :title="item.color"></i><strong>{{ palette.label }}</strong></div><div class="harmony-meter"><span :style="{ width: `${palette.score}%` }"></span></div></div>
                <div class="look-items"><div class="section-line"><h3>In this look</h3><button @click="openLook()">Edit outfit</button></div><div v-for="item in outfitItems" :key="item.id" class="look-item"><img :src="item.image" :alt="item.name" /><span><strong>{{ item.name }}</strong><small>{{ item.category }} · {{ item.color }}</small></span><i :style="{ backgroundColor: item.colorHex }"></i></div></div><p v-if="selectedLook.note" class="look-note">“{{ selectedLook.note }}”</p>
              </template><div v-else class="empty-outfit"><div class="empty-icon"><IonIcon :icon="shirtOutline" /></div><h3>A day with possibility.</h3><p>Choose a few pieces and give this day a look of its own.</p><button class="secondary-button" @click="openLook()"><IonIcon :icon="addOutline" />Build an outfit</button></div>
              <div class="weather-strip"><IonIcon :icon="sunnyOutline" /><div><strong>Clear skies on the horizon</strong><small>26° high · Light layers feel right</small></div></div>
            </aside>
          </div>
          <div class="week-note"><span><IonIcon :icon="sparklesOutline" /></span><div><small>YOUR WEEK, CURATED</small><p>{{ Object.keys(state.looks).length }} looks planned · Let every day have its own approach.</p></div><button @click="page = 'Closet'">Explore the closet →</button></div>
        </section>

        <section v-else-if="page === 'Closet'" class="page-wrap"><div class="page-heading"><div><p class="eyebrow">Everything you love to wear</p><h1>Your closet</h1><p class="heading-note">{{ state.items.length }} pieces, all in one thoughtful place.</p></div><button class="primary-button" @click="modal = 'item'"><IonIcon :icon="addOutline" />Add a piece</button></div><div class="closet-toolbar"><div class="category-filters"><button v-for="category in categories" :key="category" :class="{ active: filter.category === category }" @click="filter.category = category">{{ category }}</button></div><input v-model="filter.search" class="search-field" placeholder="Find a piece" aria-label="Search closet" /></div><div class="closet-grid"><article v-for="item in closetItems" :key="item.id" class="closet-card"><div class="closet-image"><img :src="item.image" :alt="item.name" /><span class="category-tag">{{ item.category }}</span><button class="remove-item" :aria-label="`Remove ${item.name}`" @click="removeItem(item.id)"><IonIcon :icon="trashOutline" /></button></div><div class="closet-info"><div><h3>{{ item.name }}</h3><p>{{ item.season }}</p></div><i :style="{ backgroundColor: item.colorHex }"></i></div></article><p v-if="!closetItems.length" class="no-results">No pieces found.</p></div></section>

        <section v-else-if="page === 'Style ideas'" class="page-wrap style-page"><div class="page-heading"><div><p class="eyebrow">Thoughtful combinations from your closet</p><h1>Style ideas</h1><p class="heading-note">Pairings to try, based on pieces you already own.</p></div><label class="occasion-picker">STYLE FOR<select v-model="styleOccasion"><option>Everyday</option><option>Work</option><option>Weekend</option><option>Evening</option></select></label></div><div class="stylist-intro"><div class="stylist-avatar"><IonIcon :icon="sparklesOutline" /></div><div><small>A NOTE FROM YOUR CLOSET</small><h2>A little remix goes a long way.</h2><p>These ideas pair items you have catalogued. Save one to today's outfit, then adjust anything that doesn't feel like you.</p></div></div><div class="idea-grid"><article v-for="(idea, index) in stylingIdeas" :key="idea.id" class="idea-card"><div class="idea-images"><img v-for="id in idea.items.slice(0, 3)" :key="id" :src="state.items.find((item) => item.id === id)?.image" :alt="state.items.find((item) => item.id === id)?.name" /></div><div class="idea-copy"><small>IDEA 0{{ index + 1 }} · {{ styleOccasion.toUpperCase() }}</small><h3>{{ idea.title }}</h3><p>{{ idea.note }}</p><div class="idea-swatches"><i v-for="id in idea.items" :key="id" :style="{ backgroundColor: state.items.find((item) => item.id === id)?.colorHex }"></i></div><button class="secondary-button" @click="saveStylingIdea(idea)"><IonIcon :icon="checkmarkCircle" />Wear this today</button></div></article><div v-if="!stylingIdeas.length" class="no-results">Add tops and bottoms to your closet to see outfit pairings.</div></div></section>

        <section v-else class="page-wrap insights-page"><div class="page-heading"><div><p class="eyebrow">Notice the little patterns</p><h1>Color notes</h1><p class="heading-note">A living moodboard made from the outfits you plan.</p></div></div><div class="insight-intro"><IonIcon :icon="colorPaletteOutline" /><div><small>YOUR PALETTE, LATELY</small><h2>Getting dressed in color.</h2><p>Every planned outfit adds a note to your personal color story.</p></div></div><div class="insight-swatches"><article v-for="color in [...new Set(state.items.map((item) => item.color))]" :key="color"><i :style="{ backgroundColor: state.items.find((item) => item.color === color)?.colorHex }"></i><strong>{{ color }}</strong><small>{{ state.items.filter((item) => item.color === color).length }} pieces</small></article></div><div class="approach-strip"><div><small>THE EVERYDAY APPROACH</small><h2>One palette, many moods.</h2></div><p>Try tonal layers, one bright accent, or a crisp contrast. Let each day feel a little different.</p><IonIcon :icon="sparklesOutline" /></div></section>
      </main>

      <Transition name="modal-fade"><div v-if="modal" class="modal-backdrop" @click.self="modal = ''">
        <section v-if="modal === 'look'" class="dialog outfit-dialog" role="dialog" aria-modal="true" aria-labelledby="look-title">
          <header class="dialog-header"><div><p class="eyebrow">{{ dateLabel }}</p><h2 id="look-title">{{ selectedLook ? 'Edit this look' : 'Build a look' }}</h2></div><button class="icon-button" aria-label="Close" @click="modal = ''"><IonIcon :icon="closeOutline" /></button></header>
          <div class="outfit-dialog-scroll">
            <label class="form-label">Give it a name<input v-model="lookForm.title" placeholder="e.g. Soft Sunday layers" maxlength="50" /></label>
            <label class="form-label">A note for later <small>OPTIONAL</small><textarea v-model="lookForm.note" placeholder="The feeling, the plan, the little detail…" rows="2"></textarea></label>
            <section class="outfit-preview" aria-live="polite" aria-label="Live outfit preview">
              <div class="preview-heading"><div><small>LIVE OUTFIT PREVIEW</small><strong>{{ previewItems.length ? `${previewItems.length} pieces in your look` : 'Your look will appear here' }}</strong></div><span v-if="previewItems.length">{{ previewPalette.score }}% color match</span></div>
              <div v-if="previewItems.length" class="preview-stage">
                <article v-for="category in ['Dress', 'Top', 'Bottom', 'Layer', 'Shoes', 'Accessory']" v-show="previewItems.some((item) => item.category === category)" :key="category" class="preview-piece">
                  <img v-for="item in previewItems.filter((piece) => piece.category === category)" :key="item.id" :src="item.image" :alt="item.name" />
                  <small>{{ category }}</small>
                </article>
              </div>
              <div v-else class="preview-empty"><IonIcon :icon="shirtOutline" /><span>Tap pieces below to see your outfit take shape.</span></div>
              <div v-if="previewItems.length" class="preview-color-row"><i v-for="item in previewItems" :key="item.id" :style="{ backgroundColor: item.colorHex }" :title="item.color"></i><span>{{ previewPalette.label }}</span></div>
            </section>
            <div class="piece-picker-head"><div><h3>Pick your pieces</h3><p>{{ lookForm.items.length }} selected</p></div><strong v-if="lookForm.items.length">{{ previewPalette.score }}% match</strong></div>
            <div class="piece-picker"><button v-for="item in state.items" :key="item.id" class="piece-option" :class="{ chosen: lookForm.items.includes(item.id) }" :aria-pressed="lookForm.items.includes(item.id)" @click="toggleItem(item.id)"><img :src="item.image" :alt="item.name" /><span class="piece-check"><IonIcon :icon="checkmarkCircle" /></span><span class="piece-text"><strong>{{ item.name }}</strong><small>{{ item.category }} · {{ item.color }}</small></span><i :style="{ backgroundColor: item.colorHex }"></i></button></div>
          </div>
          <footer class="dialog-footer"><button v-if="selectedLook" class="text-danger" @click="deleteLook"><IonIcon :icon="trashOutline" />Remove look</button><span v-else></span><button class="primary-button" @click="saveLook"><IonIcon :icon="checkmarkCircle" />Save look</button></footer>
        </section>
        <section v-else-if="modal === 'item'" class="dialog item-dialog" role="dialog" aria-modal="true" aria-labelledby="item-title"><header class="dialog-header"><div><p class="eyebrow">Make room for something new</p><h2 id="item-title">Add to your closet</h2></div><button class="icon-button" aria-label="Close" @click="modal = ''"><IonIcon :icon="closeOutline" /></button></header><form @submit.prevent="addItem"><label class="form-label">Piece name<input v-model="itemForm.name" placeholder="e.g. Cropped denim jacket" required maxlength="60" /></label><div class="form-row"><label class="form-label">Category<select v-model="itemForm.category"><option v-for="category in categories.slice(1)" :key="category">{{ category }}</option></select></label><label class="form-label">Season<select v-model="itemForm.season"><option>All season</option><option>Spring / Summer</option><option>Fall / Winter</option></select></label></div><div class="form-row"><label class="form-label">Color name<input v-model="itemForm.color" placeholder="sage" /></label><label class="form-label">Color swatch<input v-model="itemForm.colorHex" class="color-input" type="color" aria-label="Choose piece color" /></label></div><label class="form-label">Photo URL <small>OPTIONAL</small><input v-model="itemForm.image" type="url" placeholder="https://…" /></label><footer class="dialog-footer"><span></span><button class="primary-button" type="submit"><IonIcon :icon="addOutline" />Add piece</button></footer></form></section>
        <section v-else class="dialog settings-dialog" role="dialog" aria-modal="true" aria-labelledby="settings-title"><header class="dialog-header"><div><p class="eyebrow">Make it feel like yours</p><h2 id="settings-title">Calendar settings</h2></div><button class="icon-button" aria-label="Close" @click="modal = ''"><IonIcon :icon="closeOutline" /></button></header><div class="setting-row"><div><strong>Week begins on</strong><small>Choose the rhythm of your week.</small></div><div class="segmented"><button :class="{ active: state.settings.weekStarts === 0 }" @click="state.settings.weekStarts = 0">Sunday</button><button :class="{ active: state.settings.weekStarts === 1 }" @click="state.settings.weekStarts = 1">Monday</button></div></div><div class="setting-row"><div><strong>Look names</strong><small>Show outfit names in calendar days.</small></div><button class="toggle" :class="{ on: state.settings.showLookNames }" role="switch" :aria-checked="state.settings.showLookNames" @click="state.settings.showLookNames = !state.settings.showLookNames"><span></span></button></div><div class="setting-row"><div><strong>Calendar accent</strong><small>Choose your little color.</small></div><div class="accent-options"><button v-for="(color, name) in { forest: '#59745c', cobalt: '#536f9c', coral: '#bd6858' }" :key="name" :aria-label="name" :title="name" :class="{ active: state.settings.accent === name }" :style="{ '--swatch': color }" @click="state.settings.accent = name"><IonIcon v-if="state.settings.accent === name" :icon="checkmarkCircle" /></button></div></div><footer class="dialog-footer"><span></span><button class="primary-button" @click="modal = ''">Done</button></footer></section>
      </div></Transition>
      <Transition name="modal-fade"><div v-if="tourOpen" class="tour-backdrop" @click.self="finishTour()">
        <section class="tour-dialog" role="dialog" aria-modal="true" aria-labelledby="tour-title">
          <div class="tour-visual"><img :src="tourSteps[tourIndex].image" :alt="tourSteps[tourIndex].imageAlt" /><div class="tour-visual-wash"></div><a class="tour-brand" href="#home"><span class="brand-mark"><IonIcon :icon="sparklesOutline" /></span>thread<span class="brand-period">.</span></a><span class="tour-visual-caption">A MORE THOUGHTFUL WAY TO GET DRESSED</span><div class="tour-photo-index">0{{ tourIndex + 1 }} <span>/ 0{{ tourSteps.length }}</span></div></div>
          <div class="tour-content"><button class="tour-close" aria-label="Skip walkthrough" @click="finishTour()"><IonIcon :icon="closeOutline" /></button><div class="tour-copy"><p class="eyebrow">{{ tourSteps[tourIndex].eyebrow }}</p><h2 id="tour-title">{{ tourSteps[tourIndex].title }}</h2><p class="tour-description">{{ tourSteps[tourIndex].description }}</p><div class="tour-progress" aria-label="Walkthrough progress"><button v-for="(_, index) in tourSteps" :key="index" :class="{ current: index === tourIndex, complete: index < tourIndex }" :aria-label="`Go to walkthrough step ${index + 1}`" @click="tourIndex = index"></button></div></div><div class="tour-footer"><button class="tour-skip" @click="finishTour()">{{ tourIndex === tourSteps.length - 1 ? 'Skip for now' : 'Skip tour' }}</button><div class="tour-actions"><button v-if="tourIndex > 0" class="tour-back" @click="tourIndex -= 1">Back</button><button class="primary-button" @click="continueTour">{{ tourIndex === tourSteps.length - 1 ? 'Finish tour' : 'Continue' }}<IonIcon :icon="arrowForwardOutline" /></button></div></div><button class="tour-visit" @click="visitTourFeature()">{{ tourSteps[tourIndex].action }} <IonIcon :icon="arrowForwardOutline" /></button></div>
        </section>
      </div></Transition>
    </div>
  </IonApp>
</template>
