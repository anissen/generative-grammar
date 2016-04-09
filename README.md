# Generative Grammar [![Build Status](https://travis-ci.org/anissen/generative-grammar.svg?branch=master)](https://travis-ci.org/anissen/generative-grammar)
Parser and generator for a simple generative grammar

_Disclaimer: Work-in-progress._

## Grammar

### Definitions:
`<symbol>` := Capitalized word
`<terminal>` := Lowercase word
`<construct>` := `<symbol>` | `<terminal>`
`<result>` := `<construct> + <result>` | `<construct>`
`<probability>` := Positive number`

### Syntax:
`<symbol> => <result>`

Including a probability (optional, defaults to 1):
`<symbol> [<probability>]=> <result>`

Syntax Examples:
```
Symbol => Symbol + terminal
Symbol => terminal1
Symbol => terminal_blah1 + terminal2 + terminal3
# blah
Symbol => Symbol1 + Symbol2\nSymbol1 => terminal
# this is a comment\n\rSymbol => Symbol1 + Symbol2\nSymbol1 => terminal
Symbol [20]=> terminal1
Symbol [12.3]=> terminal1
Symbol [3.4567989]=> terminal1
```

## Example Grammars
### Quest
Grammar:
```
# generates a simple quest
Quest => SubQuest + return + Reward
SubQuest => TalkTo + Kill
SubQuest => GoTo + Retrieve
SubQuest [0.5]=> SubQuest + SubQuest
TalkTo => Person
GoTo => Location
Kill => Monster
Kill => Person
Reward => treasure
Reward [0.1]=> you_win
Retrieve => treasure
```

Example results:
```
Quest
· SubQuest
· · TalkTo
· · · Person
· · · · [ john ]
· · Kill
· · · Person
· · · · [ carl ]
· [ return ]
· Reward
· · [ you_win ]
```

```
Quest
· SubQuest
· · SubQuest
· · · TalkTo
· · · · Person
· · · · · [ john ]
· · · Kill
· · · · Monster
· · · · · [ imp ]
· · SubQuest
· · · TalkTo
· · · · Person
· · · · · [ carl ]
· · · Kill
· · · · Monster
· · · · · [ orc ]
· [ return ]
· Reward
· · [ treasure ]
```

### Map
Grammar:
```
Map => Region + Region
Region => RegionType + RegionAffilication
RegionType => island_small + Town
RegionType => island_big + City + Town
RegionAffilication => hostile
RegionAffilication => neutral
RegionAffilication => friendly
Town => House + House
City => city_center + House + House
House => House + House
House => shop
House => blacksmith
House => herbalist
House => casino
```

### Encounter
Grammar:
```
Encounter => Animals
Encounter => druid + Animals
Encounter => Monsters
Encounter => Chief + Monster + Monster
Encounter => leader + Bandits + Bandits
Encounter => Bandits
Animals => bear
Animals => wolf + wolf
Animals => rat + rat + rat
Animals => bee + bee + bee
Monsters => Monster + Monster
Monsters => Monsters + Monster
Monster => imp
Monster => ogre
Monster => slime
Chief => mage
Chief => berserker
Bandits [0.5]=> Bandits + bandit
Bandits => bandit
```
