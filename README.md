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

![image](https://github.com/Morkex/AffinityPropagation/blob/main/Images/entrada.png?raw=true)


### Matriz de Similaridad
###### Función CreaMatrizS en la biblioteca AP.nls
Esta es la matriz que nos da la información sobre lo parecidos que son los individuos entre sí.
La similaridad entre dos individuos la hemos definido de forma que podamos expresarla como otro número relacionado, el cual se calcula así: 
![image](https://github.com/Morkex/AffinityPropagation/blob/main/Images/Fsimilaridad.PNG?raw=true)

La similaridad es la distancia euclídea entre dos puntos en negativo. Cuanto mayor es la distancia entre dos puntos, menor es la similaridad entre ellos.
Aplicamos esto a todas las filas y columnas, obteniendo entonces una matriz cuadrada.

![image](https://github.com/Morkex/AffinityPropagation/blob/main/Images/similaridad1.PNG?raw=true)

####  ¿Por qué lo hacemos así?
Como vemos tenemos una diagonal de ceros, significando que los elementos son exactamente similares o iguales, lo cual tiene sentido, ya que es la similitud de un individuo consigo mismo.
Como todos los elementos estarían mapeados consigo mismos, se obtendría un mayor número de clusters.
Es por ello, que usamos el valor mínimo obtenido en la diagonal, haciendo así posible que para un individup i, un individuo j sea encontrado, donde i sea distinta de j. Otro individuo k podría ser mapeado a ese mismo individuo j, significando que es muy probable que i, j y k sean agrupados juntos en el mismo cluster.

![image](https://github.com/Morkex/AffinityPropagation/blob/main/Images/similaridad2.PNG?raw=true)


### Matriz de Responsabilidad
###### Función CreaMatrizR y Actualiza en la biblioteca AP.nls
La responsabilidad cuantifica como de bien elegido es un individuo k para ser un ejemplar del individuo i, teniendo en cuenta el individuo más cercano de esa misma columna. Usamos la siguiente fórmula:

![image](https://github.com/Morkex/AffinityPropagation/blob/main/Images/Fresponsabilidad.PNG?raw=true)


Inicializamos la matriz con 0s.
r(i, k) es el valor relativo de similaridad entre i y k, comparado con los demás individuos representados en esa misma columna (k'). La responsabilidad de k disminuirá conforme la disponibilidad de otras k' aumenten.

### Matriz de Disponibilidad
###### Función ActualizaMatrizA en la biblioteca AP.nls
La disponibilidad mide como de bueno es un ejemplar para un individuo con respecto a los individuos que representa tal ejemplar. Esto es calculado con la siguiente fórmula:

![image](https://github.com/Morkex/AffinityPropagation/blob/main/Images/Fdisponibilidad1.PNG?raw=true)

La disponibilidad es auto-responsable de k más las responsabilidades positivas o K con respecto a otros individuos que no sean i. Sólo incluimos las responsabilidades positivas ya que el ejemplar debe ser positivamente responsable y justificar algunos individuos, independientemente de lo mal que justifique los otros individuos. Si la responsabilidad es negativa, significa que k es más adecuado para ser representado por un ejemplar que serlo. El valor máximo de a(i, k) es 0.
Las disponibilidades propias se calculan así:

![image](https://github.com/Morkex/AffinityPropagation/blob/main/Images/Fdisponibilidad2.PNG?raw=true)

a(k, k) refleja la evidencia acumulada de que el punto k es adecuado para ser un ejemplo, basado en las responsabilidades positivas de k hacia otros elementos. 

### Matriz de Criterio
###### Función CreaMatrizC en la biblioteca AP.nls
La Matriz de Criterio se calcula después de que finalice las actualizaciones de R y A iterativamente. La Matriz de Criterios es la suma de R con A. Un individuo i se asignará a un ejemplar k que es responsable y está disponible para i.

![image](https://github.com/Morkex/AffinityPropagation/blob/main/Images/Fcriterio.PNG?raw=true)

El elemento con el valor de criterio más alto de cada fila sería el ejemplar. Los elementos correspondientes a las filas que comparten el mismo ejemplar se agrupan en el mismo cluster.

![image](https://github.com/Morkex/AffinityPropagation/blob/main/Images/criterio.PNG?raw=true)

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
