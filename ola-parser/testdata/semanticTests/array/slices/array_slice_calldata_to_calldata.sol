pragma abicoder v2;

contract C {
    struct S {
        uint128 p1;
        u256[3] a;
        uint32 p2;
    }
    fn f(S[]  c) internal -> (S[] memory) {
        return c;
    }
    fn g(S[]  c, u256 s, u256 e)  -> (S[] memory) {
        return f(c[s:e]);
    }

    fn f1(u256[3][]  c) internal -> (u256[3][] memory) {
        return c;
    }
    fn g1(u256[3][]  c, u256 s, u256 e)  -> (u256[3][] memory) {
        return f1(c[s:e]);
    }
}
// ====
// compileViaYul: also
// ----
// g((uint128,u256[3],uint32)[],u256,u256): 0x60, 1, 3, 4, 55, 1, 2, 3, 66, 66, 2, 3, 4, 77, 77, 3, 4, 5, 88, 88, 4, 5, 6, 99 -> 0x20, 2, 66, 2, 3, 4, 77, 77, 3, 4, 5, 88
// g1(u256[3][],u256,u256): 0x60, 1, 3, 4, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 -> 0x20, 2, 4, 5, 6, 7, 8, 9