package generativegrammar;

class TreeTools {
    static public function leafs<T>(t :Tree<T>) :Array<T> {
        return switch (t) {
            case Leaf(v): [v];
            case Node(v, list): var tmp = []; for (l in list) tmp = tmp.concat(leafs(l)); tmp;
        }
    }
}
