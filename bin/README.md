La imposición es el orden de páginas de un PDF para enviarlo a imprimir.
Este script intenta crearla de forma que sólo haya que cortar al menos
una vez, para folletos cortos que se pueden abrochar, o dos si se va a
encuadernar.

         anverso                 reverso
    +-------+-------+       +-------+-------+
    |       |       |       |       |       |
    |       |       |       |       |       |
    |   8   |   1   |       |   2   |   7   |
    |       |       |   g   |       |       |
    |       |       |   i   |       |       |
    +-------+-------+ > r > +-------+-------+
    |       |       |   a   |       |       |
    |       |       |   r   |       |       |
    |   5   |   4   |       |   3   |   6   |
    |       |       |       |       |       |
    |       |       |       |       |       |
    +-------+-------+       +-------+-------+

Se corta por el medio y se apilan las páginas.  Si el PDF no tiene
páginas que sean múltiplo de 4, se agregan páginas en blanco
automáticamente.


## TODO

* Para libros grandes que se van a doblar a mano la imposición no es
  completa, debería dividir en cuadernillos más chicos en lugar de la
  mitad de páginas

## Requisitos

pdfjam (parte de texlive) y pdfinfo (parte de poppler)
