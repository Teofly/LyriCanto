# Prompt Engineering Guide for LyriCanto

## Objective
Transform song lyrics while maintaining melodic compatibility, rhyme schemes, and syllabic structure across languages.

## Core Principles

### 1. Metric Faithfulness
Every verse must match the syllable count of the original, ensuring singability to the same melody.

**Example:**
```
Original (English, 8 syllables):
"I want to break free from your lies"

Target (Italian, 8 syllables):
"Voglio scappare dalle tue bugie"
```

### 2. Rhyme Scheme Preservation
Maintain the rhyme pattern (ABAB, AABB, etc.) across language boundaries.

**Example ABAB:**
```
Original:
A: "In the middle of the night" (night)
B: "I go walking in my sleep" (sleep)
A: "Through the valley of the night" (night - rhymes with A)
B: "To the river so deep" (deep - rhymes with B)

Italian Translation (preserving ABAB):
A: "Nel mezzo della notte oscura" (oscura)
B: "Cammino dentro il mio sogno" (sogno)
A: "Attraverso quella pianura" (pianura - rhymes with A)
B: "Verso il fiume più lontano" (lontano - assonance with B)
```

### 3. Phonetic Similarity Strategies

#### High Similarity (0.7-1.0)
Focus on consonance, assonance, and alliteration that mirror the original sounds.

**Example:**
```
EN: "Shake it off, shake it off" (/ʃeɪk/)
IT: "Scuoti via, scuoti via" (/sku/)
    → Similar /sk-/ sound cluster
```

#### Medium Similarity (0.4-0.6)
Maintain vowel sounds or stress patterns.

**Example:**
```
EN: "Take me home" (long 'o' sound)
IT: "Portami via" (maintain open vowels)
```

#### Low Similarity (0.0-0.3)
Focus purely on semantic content and metric compatibility.

### 4. Section Structure
Preserve the architecture: verse, chorus, bridge, intro, outro.

**Template:**
```
[STROFA 1]
8 syllables - A
7 syllables - B
8 syllables - A
7 syllables - B

[RITORNELLO]
6 syllables - C
6 syllables - C
8 syllables - D
8 syllables - D

[STROFA 2]
(repeat pattern of Strofa 1)
```

## Few-Shot Examples

### Example 1: English to Italian (Travel Theme)

**Original:**
```
I've been everywhere, man (7 syllables)
I've crossed the desert bare, man (8 syllables)
Of travel I've had my share, man (9 syllables)
I've been everywhere (6 syllables)
```

**Rewritten (Tema: Viaggio a Trieste):**
```
Ho visto il mondo, sai (7 syllables)
Da Trieste fino ai guai (8 syllables)
Ho viaggiato dove vai (9 syllables)
Ho visto tutto ormai (6 syllables)

Rhyme scheme: AAAA maintained
Phonetic: "man" → "sai/guai/vai/mai" (similar open ending)
```

### Example 2: Spanish to Italian (Technology Theme)

**Original:**
```
[ESTRIBILLO]
Bailando bajo las estrellas (10 syllables) - A
Sintiendo el ritmo en las venas (10 syllables) - A
```

**Rewritten (Tema: Tecnologia):**
```
[RITORNELLO]
Navigando tra le connessioni (10 syllables) - A
Sentendo il bit nelle emozioni (10 syllables) - A

Rhyme: -ones/-oni (phonetically similar)
Meter: Preserved 10 syllables per line
```

### Example 3: Multi-Syllabic Rhymes

**Original:**
```
You could be the one to make me feel that way (13 syllables)
You could be the key to lead me to a place (13 syllables)
```

**Rewritten:**
```
Potresti essere tu quello che mi fa sognare (13 syllables)
Potresti avere in te la chiave per volare (13 syllables)

Multi-syllabic rhyme: "sognare/volare"
```

## Implementation Checklist

When generating rewritten lyrics, Claude must:

1. ✅ Count syllables per line and match the original
2. ✅ Identify the rhyme scheme (ABAB, AABB, ABCABC, etc.)
3. ✅ Maintain section boundaries (verse/chorus/bridge)
4. ✅ Apply phonetic similarity at the requested strength
5. ✅ Integrate the new topic/theme naturally
6. ✅ Preserve the emotional arc and energy of the song
7. ✅ Flag any lines that couldn't match syllable count perfectly

## Common Pitfalls to Avoid

❌ Don't: Add extra syllables for semantic completeness
✅ Do: Prioritize singability and truncate if needed

❌ Don't: Force perfect rhymes at the cost of meaning
✅ Do: Use assonance and consonance as alternatives

❌ Don't: Ignore the song's rhythm and stress patterns
✅ Do: Consider where the melodic emphasis falls

## Output Format

Provide only the rewritten text, preserving:
- Line breaks
- Section markers (if present)
- Blank lines between sections

Do NOT include:
- Explanations
- Syllable counts
- Commentary
- Analysis

Claude should output clean, singable lyrics ready for immediate use.

---

## Validation Notes

After generation, the MetricsValidator will:
- Count syllables per line
- Compare against the original
- Generate a compatibility score (0.0-1.0)
- Flag lines with >2 syllable deviation

Target score: ≥0.85 for production use
