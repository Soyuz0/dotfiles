def foo1(x):
    print(x)


foo1("a")


def foo2(x, y):
    foo1(x)
    print(x)
    print(y)


foo2("a", y="b")


def foo25(x, y=5):
    print(x)


foo25(2)


def foo26(x, **kwargs):
    print(x)


foo26("a")


def foo3(**kwargs):
    print(kwargs)


foo3(a=2)


def foo4(*args):
    print(*args)


foo4("5")


def foo5(x, *args, y=5, **kwargs):
    print(x)


foo5(1, 2)


class X:
    def __init__(self, x=5):
        self.x = x

    def foo6(self, x):
        print(x)


x = X(2)
x.foo6("a")
str(1)
