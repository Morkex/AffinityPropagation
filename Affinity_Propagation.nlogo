extensions [matrix]
__includes ["AP.nls"]
globals[Data]

breed [dataPoints dataPoint]

dataPoints-own [
 S-value
 R-value
 A-value
 C-value
  atributos

]

to setup
  ca
  resize-world 0 10 0 10
  ask patches[
    set pcolor white
  ]
  let lista (list)

    file-open user-file
    while [not file-at-end?] [
      set lista lput file-read lista
    ]

  file-close-all
  set Data matrix:from-row-list lista
  let row 0
  let col 0
  while [row < first matrix:dimensions Data][

    create-dataPoints 1 [

      set atributos matrix:get-row Data row
      set xcor first atributos
      set ycor last atributos
      set size 0.2
    ]
    set row row + 1
  ]

end

to matrizS
  CreaMatrizS Data Iteraciones
end

to matrizR
  CreaMatrizR
end

to matrizC
  CreaMatrizC
  let l GetEjemplares
  coloring l
end

to coloring [l]
  let cont 0
  let contcol 5
  let listaejemplares remove-duplicates l

  while [cont < length l][
    ask dataPoint cont[
      if (cont != (item cont l))[
        create-link-to  dataPoint (item cont l)[set color black]
      ]
    ]
    set cont cont + 1
  ]

  foreach listaejemplares [x -> ask dataPoint x [
    set color contcol
    ask in-link-neighbors[set color contcol]
    set contcol contcol + 10
    ]
  ]

end








@#$#@#$#@
GRAPHICS-WINDOW
210
10
731
532
-1
-1
46.64
1
10
1
1
1
0
1
1
1
0
10
0
10
0
0
1
ticks
30.0

BUTTON
25
28
89
61
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
26
102
150
135
Imprime Matriz C
matrizC
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
26
140
181
173
Iteraciones
Iteraciones
2
50
3.0
1
1
NIL
HORIZONTAL

BUTTON
26
66
89
99
GO
MatrizS
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@



# 3º Proyecto Inteligencia Artificial
## Integrantes del Grupo
* CHAMBER GONZALEZ DE QUEVEDO, ENRIQUE
* MARTÍN AUDÉN, ALEJANDRO
* RUIZ JURADO, PABLO
## Proyecto Número 2
Implementa el algoritmo de clustering llamado [**Affinity Propagation** ](https://en.wikipedia.org/wiki/Affinity_propagation "This link opens in a new window: https://en.wikipedia.org/wiki/Affinity_propagation") 

### ¿Qué es Affinity Propagation?
En estadística y Data Mining, la Affinity Propagation (AP) es un algoritmo de Clustering basado en el concepto de "paso de mensajes" entre datapoints. A diferencia de otros algoritmos de clustering como K-medias o K-medoids, AP no requiere que sea especificado el número de agrupaciones o clusters antes de ejecutarse. Al igual que K-medoids, AP encuentra ejemplares, miembros del conjunto de entrada que representan esas agrupaciones.

Affinity Propagation fue publicado en 2007 por Brendan Frey y Delbert Dueck en la revista científica [**Science** ](https://ieeexplore.ieee.org/abstract/document/4408853)

#### Conceptos Importantes
* **Clustering:** Agrupaciones, conjuntos de individuos similares.
* **Datapoints:** Individuos con información relevante
* **K-medias:** Algoritmo de clustering que tiene como objetivo la partición de un conjunto de n observaciones e k grupos, en el que cada observación pertenece al grupo cuyo valor medio es más cercano. Es un método muy utilizado en Data Mining.
* **Ejemplares:** Un ejemplar es un individuo que caracteriza a un clúster, en este caso el mayor/menor valor de ese cluster.

## Explicación superficial
AP coge como entrada las similitudes entre los datapoints e identifica los ejemplares basados en un cierto criterio. Los mensajes son intercambiados entre los datapoints hasta que haya varios conjuntos de ejemplares notorios.
Los datos de los individuos son introducidos en una matriz, con la cual se va a trabajar. 
1. Primero haremos la matriz de similaridad, la cual nos da información sobre lo parecidos que son los individuos entre sí. 
2. Después calcularemos la matriz de responsabilidad, la cual cuantifica como de bien situado está un elemento si está representado por otro. 
3. La matriz de disponibilidad es calculada a partir de la de responsabilidad, en la cual se comprueba como de bueno es un ejemplar para un individuo con respecto a los individuos que representa tal ejemplar. 
4. Por último obtenemos la matriz de criterio, calculada después de realizar todos los mensajes entre matrices. En esta matriz vemos al fin los ejemplares, ya que se crea a partir de las matrices de responsabilidad y disponibilidad. 

El elemento con mayor valor en cada fila en la matriz final es un ejemplar. Los individuos que corresponden a las filas que comparten el mismo ejemplar serán agrupados juntos.

## Interfaz
* **Entrada de Datos:** Los datos deben ser introducidos mediante un fichero con una estructura tal que así (Siendo x valores enteros, cada fila es un individuo, y cada columna una característica) [x x x] [x x x] [x x x]

* **Setup:** Inicia el programa, y muestra en pantalla las posiciones iniciales de los individuos.

* **GO:** Realiza los envíos de mensajes entre las matrices R y A un número de veces igual a Iteraciones y las imprime en la terminal.

* **Imprimir Matriz de Criterio:** Imprime en la terminal la matriz final C y crea los links entre los individuos representados y los ejemplares.

* **Iteraciones:** Número de iteraciones deseadas.

> Aportamos tres matrices de ejemplo: 

> * La llamada MatrizEjemplo.txt es la misma que la que usamos en esta documentación para representar. 

> * La llamada Matriz4x5.txt es una matriz 4x5

> * La llamada Matriz10x2.txt es una matriz 10x2  


## Las matemáticas del algoritmo
Todo el algoritmo está realizado con operaciones sobre matrices, usando sus propiedades para encontrar los ejemplares y agrupar. Además, cada "mensaje" es en realidad una iteración en el algoritmo, cambiando esto los valores de la matriz final. Se va a desarrollar un mismo ejemplo para su mejor comprensión.

### Matriz de Entrada
La matriz de entrada es la introducida por el usuario, esta debe incluir unos individuos y unas características de estos. A partir de aquí se calculan todas las demás.

![image](.\Images\entrada.png)


### Matriz de Similaridad
###### Función CreaMatrizS en la biblioteca AP.nls
Esta es la matriz que nos da la información sobre lo parecidos que son los individuos entre sí.
La similaridad entre dos individuos la hemos definido de forma que podamos expresarla como otro número relacionado, el cual se calcula así: 
![image](.\Images\Fsimilaridad.png)

La similaridad es la distancia euclídea entre dos puntos en negativo. Cuanto mayor es la distancia entre dos puntos, menor es la similaridad entre ellos.
Aplicamos esto a todas las filas y columnas, obteniendo entonces una matriz cuadrada.
![image](.\Images\similaridad1.png)

####  ¿Por qué lo hacemos así?
Como vemos tenemos una diagonal de ceros, significando que los elementos son exactamente similares o iguales, lo cual tiene sentido, ya que es la similitud de un individuo consigo mismo.
Como todos los elementos estarían mapeados consigo mismos, se obtendría un mayor número de clusters.
Es por ello, que usamos el valor mínimo obtenido en la diagonal, haciendo así posible que para un individup i, un individuo j sea encontrado, donde i sea distinta de j. Otro individuo k podría ser mapeado a ese mismo individuo j, significando que es muy probable que i, j y k sean agrupados juntos en el mismo cluster.

![image](.\Images\similaridad2.png)


### Matriz de Responsabilidad
###### Función CreaMatrizR y Actualiza en la biblioteca AP.nls
La responsabilidad cuantifica como de bien elegido es un individuo k para ser un ejemplar del individuo i, teniendo en cuenta el individuo más cercano de esa misma columna. Usamos la siguiente fórmula:
![image](.\Images\Fresponsabilidad.png)


Inicializamos la matriz con 0s.
r(i, k) es el valor relativo de similaridad entre i y k, comparado con los demás individuos representados en esa misma columna (k'). La responsabilidad de k disminuirá conforme la disponibilidad de otras k' aumenten.

### Matriz de Disponibilidad
###### Función ActualizaMatrizA en la biblioteca AP.nls
La disponibilidad mide como de bueno es un ejemplar para un individuo con respecto a los individuos que representa tal ejemplar. Esto es calculado con la siguiente fórmula:
![image](.\Images\Fdisponibilidad1.png)

La disponibilidad es auto-responsable de k más las responsabilidades positivas o K con respecto a otros individuos que no sean i. Sólo incluimos las responsabilidades positivas ya que el ejemplar debe ser positivamente responsable y justificar algunos individuos, independientemente de lo mal que justifique los otros individuos. Si la responsabilidad es negativa, significa que k es más adecuado para ser representado por un ejemplar que serlo. El valor máximo de a(i, k) es 0.
Las disponibilidades propias se calculan así:
![image](.\Images\Fdisponibilidad2.png)

a(k, k) refleja la evidencia acumulada de que el punto k es adecuado para ser un ejemplo, basado en las responsabilidades positivas de k hacia otros elementos. 

### Matriz de Criterio
###### Función CreaMatrizC en la biblioteca AP.nls
La Matriz de Criterio se calcula después de que finalice las actualizaciones de R y A iterativamente. La Matriz de Criterios es la suma de R con A. Un individuo i se asignará a un ejemplar k que es responsable y está disponible para i.
![image](.\Images\Fcriterio.png)

El elemento con el valor de criterio más alto de cada fila sería el ejemplar. Los elementos correspondientes a las filas que comparten el mismo ejemplar se agrupan en el mismo cluster.
![image](.\Images\criterio.png)

En este caso A es el ejemplar de B y de C (Y de sí mismo). Además, D es el ejemplar de E.

### Iteraciones
Las matrices R y A se actualizan iterativamente, ese número de veces es introducido por el usuario. Dependiendo de lo grande que sea la matriz, convergerá antes o después a una misma matriz.


## Interpretación de los datos Visualmente
Cada Individuo está representado en un mundo 10x10 de Netlogo en una posición en concreto, siendo su primera característica su coordenada x y su última característica la coordenada y. Una vez se ejecuta el algoritmo con las iteraciones deseadas podemos ver como han ido evolucionando en el terminal. Finalmente podemos pasar a mostrar la matriz de criterio, esta estará escrita en el terminal también, además, se dibujarán links entre los individuos, de individuo representado a individuo ejemplar. Cada cluster es de un color diferente para simplificar su interpretación.
### Función GetEjemplares
Devuelve una lista con el ejemplar del elemento íesimo de la lista, usado para facilitar la representación visual.

# Bibliografía
* [Wikipedia: Affinity Propagation](https://en.wikipedia.org/wiki/Affinity_propagation). Artículo de Wikipedia principal.
* [How Affinity Propagation works?](https://towardsdatascience.com/math-and-intuition-behind-affinity-propagation-4ec5feae5b23) Página de dónde hemos sacado los ejemplos y basado la explicación.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 135 180
Line -7500403 true 150 150 165 180
@#$#@#$#@
0
@#$#@#$#@
