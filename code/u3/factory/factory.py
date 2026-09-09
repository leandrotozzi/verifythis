"""Factory pattern example, in Python."""
import random


class Trago:
    """Factory class that builds a Trago."""

    @staticmethod
    def factory(kind):
        """Factory Method."""
        if kind == "CubaLibre":
            return CubaLibre()
        if kind == "Fernet":
            return Fernet()
        if kind == "Mojito":
            return Mojito()
        if kind == "Whiscola":
            return Whiscola()
        raise ValueError("No such trago: " + kind)


class CubaLibre(Trago):
    """Rum and coke."""

    def hielo(self):
        """Ice cubes."""
        print("CubaLibre.hielo: 2")

    def graduacion(self):
        """Strength."""
        print("CubaLibre.graduacion: medium")


class Whiscola(Trago):
    """Whisky and coke."""

    def hielo(self):
        """Ice cubes."""
        print("Whiscola.hielo: 2")

    def graduacion(self):
        """Strength."""
        print("Whiscola.graduacion: strong")


class Fernet(Trago):
    """Fernet and coke."""

    def hielo(self):
        """Ice cubes."""
        print("Fernet.hielo: 3")

    def graduacion(self):
        """Strength."""
        print("Fernet.graduacion: strong")


class Mojito(Trago):
    """Mint, lime and soda."""

    def hielo(self):
        """Ice cubes."""
        print("Mojito.hielo: 5")

    def graduacion(self):
        """Strength."""
        print("Mojito.graduacion: light")


# Generate Tragos: at random
def trago_generator(n):
    """Factory Method."""
    # Ask the language for every subclass that inherits from Trago
    types = Trago.__subclasses__()
    # Build a generator
    for _ in range(n):
        yield random.choice(types).__name__


tragos = [Trago.factory(kind) for kind in trago_generator(20)]


# It does not matter which trago comes out: they all get served the same
for trago in tragos:
    trago.hielo()
    trago.graduacion()
