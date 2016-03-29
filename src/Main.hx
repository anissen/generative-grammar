
class Main {
    static function main() {
        var quest_grammar =
        "Quest => SubQuest + return + Reward
        SubQuest => TalkTo + Kill
        SubQuest => GoTo + Retrieve
        SubQuest [0.5]=> SubQuest + SubQuest
        TalkTo => Person
        GoTo => Location
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
        function print(s :String, index :Int) {
            //if (s.charAt(0) == s.charAt(0).toLowerCase()) trace(s); // only print lower-case strings
            trace(pad(index) + s);
        }
        function print_tree(t :Generator.Tree<String>, index :Int = 0) {
            return switch (t) {
                case Leaf(s): print(s, index);
                case Node(s, list): print(s, index); for (l in list) print_tree(l, index + 1);
                default: trace('Invalid!', index);
            }
        }

        var generator = new Generator();
        generator.add_rules(map_grammar);
        generator.add_rules(quest_grammar);
        generator.add_rules(encounter_grammar);

        var results_tree = generator.generate('Quest');
        print_tree(results_tree);
    }
}
