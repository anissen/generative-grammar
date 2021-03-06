import generativegrammar.Generator;
import generativegrammar.Tree;

class Main {
    static function main() {
        var quest_grammar =
        "Quest => SubQuest + return + Reward
        SubQuest => TalkTo + Kill
        SubQuest => GoTo + Retrieve
        SubQuest [0.5]=> SubQuest + SubQuest
        TalkTo => Person
        Person => john
        Person => carl
        GoTo => Location
        Location => the_swamp
        Location => the_mountains
        Monster => orc
        Kill => Monster
        Kill => Person
        Reward => treasure
        Reward [0.1]=> you_win
        #Reward => treasure + Reward
        Retrieve => treasure";

        var map_grammar = "
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
        ";

        var encounter_grammar = "
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
        ";

        function pad(size :Int) {
            var s = '';
            for (i in 0 ... size) s += ' ·';
            return s + ' ';
        }
        function print_tree(t :Tree<String>, index :Int = 0) {
            return switch (t) {
                case Leaf(s): trace(pad(index) + '[ $s ]');
                case Node(s, list): trace(pad(index) + s); for (l in list) print_tree(l, index + 1);
            }
        }

        var generator = new Generator();
        generator.add_rules(map_grammar);
        generator.add_rules(quest_grammar);
        generator.add_rules(encounter_grammar);

        generator.set_validation(function(s) {
            if (s == 'Kill') return false; // pacifist mode; won't get any quests involving killing
            return true; 
        });
        var results_tree = generator.generate('Quest');
        print_tree(results_tree);
    }
}
