"""Factory pattern example, in Python."""
from __future__ import generators
import random


class Trago(object):
    """Factory class that builds a Trago."""

    def factory(type):
        """Factory Method."""
        if type == "CubaLibre":
            return CubaLibre()
        if type == "Fernet":
            return Fernet()
        if type == "Mojito":
            return Mojito()
        if type == "Whiscola":
            return Whiscola()
        assert 0, "No such trago: " + type
    factory = staticmethod(factory)


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
    for i in range(n):
        yield random.choice(types).__name__

Tragos = [Trago.factory(i) for i in trago_generator(20)]


# It does not matter which trago comes out: they all get served the same
for Trago in Tragos:
    Trago.hielo()
    Trago.graduacion()
