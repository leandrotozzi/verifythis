"""Ejemplo banana de Factory en Python."""
from __future__ import generators
import random


class Trago(object):
    """Clase Factory que arma Trago."""

    def factory(type):
        """Factory Method."""
        if type == "CubaLibre":
            return CubaLibre()
        if type == "Fernet":
            return Fernet()
        if type == "Gancia":
            return Gancia()
        if type == "Whiscola":
            return Whiscola()
        assert 0, "Creaste mal el trago: " + type
    factory = staticmethod(factory)


class CubaLibre(Trago):
    """Ron con coca."""

    def hielo(self):
        """Hielito."""
        print("CubaLibre.hielo: 2")

    def graduacion(self):
        """Alcohol."""
        print("CubaLibre.graduacion: pecho")


class Whiscola(Trago):
    """Whisky con coca."""

    def hielo(self):
        """Hielito."""
        print("Whiscola.hielo: 2")

    def graduacion(self):
        """Alcohol."""
        print("Whiscola.graduacion: bien")


class Fernet(Trago):
    """Cuadrados."""

    def hielo(self):
        """Hielito."""
        print("Fernet.hielo: 3")

    def graduacion(self):
        """Alcohol."""
        print("Fernet.graduacion: tibio")


class Gancia(Trago):
    """Gancia con Sprite."""

    def hielo(self):
        """Hielito."""
        print("Gancia.hielo: 5")

    def graduacion(self):
        """Alcohol."""
        print("Gancia.graduacion: ultra-pecho")


# Generate Tragos: de una manera random
def trago_generator(n):
    """Factory Method."""
    # Pedimos que nos entreguen todas las subclases heredadas
    types = Trago.__subclasses__()
    # Armamos un generador
    for i in range(n):
        yield random.choice(types).__name__

Tragos = [Trago.factory(i) for i in trago_generator(20)]


# No importa que tipo de trago estoy pidiendo, lo tomo igual
for Trago in Tragos:
    Trago.hielo()
    Trago.graduacion()
