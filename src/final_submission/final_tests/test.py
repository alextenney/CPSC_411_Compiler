# // should be 2903040, in case you're wondering

# int foo(int a, int b, int c, int d) {
# 	return a * b * c * d;
# }

# int d;

# int bar(int a, int b, int c) {
#         return foo(a, b, c, d-3);
# }

# int baz(int a) {
# 	d = d + 1;
# 	return a;
# }


# mane() {
# 	d = 10;
# 	printi(foo(1, bar(2, baz(3), 4), bar(5, baz(6), 7), baz(8)));
# 	prints("\n");
d = 0

def foo(a, b, c, d):
    return a * b * c * d

def bar (a, b, c):
    return foo(a, b, c, d-3)

def baz(a):
    d = d + 1
    return a

def main():
    d = 10
    print(foo(1, bar(2, baz(3), 4), bar(5, baz(6), 7), baz(8)))

if __name__ == "__main__":
    main()