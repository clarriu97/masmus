# Reglas del Mus en Más Mus

La especificación que implementa el motor (`lib/game/`). Cada regla tiene un
identificador estable (`R-…`) que su test nombra; los ejemplos (`E-…`) y las
manos completas (`S-…`) se usan tal cual en los tests. Cambiar una regla es
cambiar este documento y sus tests en la misma PR.

Por defecto se sigue lo que marcan los reglamentos de ASESMUS, Madrid,
Barcelona, Bizkaia y Navarra (ver `docs/PRODUCT.md` → Rules players expect):
**8 reyes, a 40 tantos, mus corrido en la primera mano, sin 31 real y sin
deje**. En la v1 se puede elegir **4 reyes** y **30 tantos**.

Notación de los ejemplos: las cartas por su número (`1`–`7`), `S` sota, `C`
caballo, `R` rey; el palo solo se escribe cuando importa (`Ro` rey de oros,
`7e` siete de espadas, `1b` as de bastos, `5c` cinco de copas).

## 1. Baraja y valores

- **R-BAR-1.** Baraja española de 40 cartas: oros, copas, espadas y bastos;
  en cada palo 1 (as) a 7, sota, caballo y rey.
- **R-BAR-2.** Con **8 reyes** (por defecto) los treses son reyes y los doses
  son ases a todos los efectos: grande, chica, pares, juego y punto. Con
  **4 reyes** cada carta es lo que es.
- **R-BAR-3.** Orden de mayor a menor para grande, chica y pares: rey,
  caballo, sota, 7, 6, 5, 4, 3, 2, as. Con 8 reyes queda rey (y tres),
  caballo, sota, 7, 6, 5, 4, as (y dos).
- **R-BAR-4.** Valor para juego y punto: sota, caballo y rey valen 10; el
  resto, su número. Con 8 reyes el tres vale 10 y el dos vale 1.

## 2. Jugadores, mano y postre

- **R-ORD-1.** Cuatro jugadores en dos parejas; los compañeros se sientan
  enfrente.
- **R-ORD-2.** Se habla por orden, en sentido antihorario: primero la
  **mano**, al final el **postre**. Todas las decisiones de la mano (mus,
  descartes, declaraciones, envites) siguen este orden.
- **R-ORD-3.** En la mano siguiente es mano el jugador que venía después de
  la mano actual en el orden de habla.
- **R-ORD-4.** La mano inicial del primer juego se sortea. En la primera mano
  de cada juego hay mus corrido (R-MUS-5).
- **R-ORD-5.** Nadie ve las cartas de los demás hasta el recuento, salvo en un
  órdago querido, en el que se enseñan en el acto.

## 3. Reparto, mus y descartes

- **R-MUS-1.** Se reparten cuatro cartas a cada jugador.
- **R-MUS-2.** Desde la mano, cada jugador dice **"mus"** o **"no hay mus"**.
  En cuanto uno dice "no hay mus" se corta el mus y empiezan los lances, con
  la mano hablando primero; si los cuatro dicen "mus", hay descarte.
- **R-MUS-3.** En el descarte, cada jugador aparta de 1 a 4 cartas. Cuando
  los cuatro han elegido, se sirve a cada uno, desde la mano, tantas cartas
  del mazo como ha apartado. Después se vuelve a hablar de mus (R-MUS-2).
- **R-MUS-4.** Si al servir a un jugador el mazo no tiene cartas suficientes,
  recibe las que quedan y el resto sale de un mazo nuevo: se barajan todos los
  descartes (incluidos los de esa ronda). Las cartas que están en la mano de
  un jugador nunca vuelven al mazo.
- **R-MUS-5.** **Mus corrido.** En la primera mano de cada juego, cada vez
  que los cuatro dicen "mus", tras el descarte la mano pasa al jugador
  siguiente, que empieza a hablar de mus. Quien corta el mus pasa a ser la
  mano de esa mano y los lances empiezan por él. Mientras dura el mus corrido
  no se pueden hacer señas.

## 4. Lances y cómo se comparan las manos

- **R-LAN-1.** Los lances se juegan en este orden: **grande**, **chica**,
  **pares** y **juego**; si nadie tiene juego, se juega el **punto** en su
  lugar.
- **R-LAN-2.** **Grande.** Se ordenan las cartas de mayor a menor (R-BAR-3):
  gana la mano con la primera carta más alta; si empatan, la segunda, y así
  hasta la cuarta.
- **R-LAN-3.** **Chica.** Se ordenan las cartas de menor a mayor: gana la mano
  con la primera carta más baja; si empatan, la segunda más baja, y así hasta
  la cuarta.
- **R-LAN-4.** **Pares.** Tiene pares quien tiene al menos dos cartas del
  mismo valor (R-BAR-3). De menos a más: **par** (dos iguales), **medias**
  (tres iguales) y **duples** (dos parejas, o cuatro iguales, que cuentan como
  dos parejas iguales). Entre dos manos del mismo tipo gana la de cartas más
  altas en la jugada: el par más alto; las medias más altas; en duples, la
  pareja más alta y, si empatan, la otra. Las cartas que no forman parte de la
  jugada no desempatan.
- **R-LAN-5.** **Juego.** Tiene juego quien suma 31 o más (R-BAR-4). De mejor
  a peor: **31**, 32, 40, 37, 36, 35, 34 y 33 (38 y 39 no se pueden formar).
- **R-LAN-6.** **Punto.** Solo se juega si nadie tiene juego. Gana la suma más
  alta (30 como máximo).
- **R-LAN-7.** **Empates.** Si dos manos empatan en un lance, gana la del
  jugador que habla antes (el más cercano a la mano). Entre parejas se
  comparan las mejores manos de cada una, con este mismo desempate.

## 5. Declaraciones de pares y juego

- **R-DEC-1.** Antes del lance de pares, cada jugador dice desde la mano si
  tiene pares. En la app lo dice el motor por él y siempre es verdad.
- **R-DEC-2.** En el lance de pares solo hablan quienes tienen pares. Si solo
  una pareja tiene pares, no se apuesta: el lance es **sin disputa** y se
  cuenta al final (R-REC-3). Si nadie tiene pares, no hay lance.
- **R-DEC-3.** Lo mismo para el juego: declaración desde la mano, solo hablan
  quienes tienen juego y un lance sin disputa se cuenta al final. Si nadie
  tiene juego, se juega el punto (R-LAN-6), en el que hablan los cuatro.

## 6. Envites

- **R-ENV-1.** En cada lance hablan por orden, desde la mano, los jugadores
  que pueden jugarlo. Cada uno puede **pasar**, **envidar** (2 tantos o más)
  o echar un **órdago**.
- **R-ENV-2.** Si todos los que pueden hablar pasan, el lance queda **en
  paso**.
- **R-ENV-3.** Ante un envite responde la pareja contraria, empezando por el
  primero de ellos que habla después del que envidó y que puede jugar el
  lance. Puede **querer**, **no querer**, **reenvidar** ("X más", al menos 2)
  o echar un **órdago**. Si no quiere, decide su compañero, si puede jugar el
  lance. Basta con que uno de los dos quiera. Haber pasado antes no impide
  responder.
- **R-ENV-4.** Un reenvite cambia de lado la respuesta: contesta la pareja que
  envidó, con las mismas opciones (R-ENV-3).
- **R-ENV-5.** **Quiero.** El lance se cierra con lo envidado en la mesa y se
  resuelve en el recuento.
- **R-ENV-6.** **No quiero.** El lance lo gana la pareja que hizo el último
  envite, que cobra en el acto **1 tanto** si era el primer envite del lance,
  o **lo último que se aceptó** si hubo reenvites: lo que había en la mesa
  antes del envite rechazado. En pares, juego y punto, además, esa pareja
  cobra en el recuento los tantos de sus jugadas (R-REC-3 a R-REC-5).
- **R-ENV-7.** **Órdago.** Una apuesta por el juego entero. Si se quiere, se
  resuelve en el acto (R-FIN-3). Si no se quiere, se aplica R-ENV-6 con lo
  que hubiera en la mesa antes del órdago.
- **R-ENV-8.** Un lance cerrado (en paso, querido o no querido) no se vuelve
  a abrir.

## 7. Recuento

- **R-REC-1.** Al acabar el último lance, si nadie ha ganado ya la partida, se
  enseñan las cartas y se cuenta en este orden: grande, chica, pares y juego
  (o punto).
- **R-REC-2.** **Grande y chica.** En paso: 1 tanto para la mejor mano.
  Querido: lo envidado, para la mejor mano. No querido: ya se cobró en el
  acto (R-ENV-6).
- **R-REC-3.** **Pares.** Cada jugador de la pareja ganadora que tiene pares
  suma sus tantos: par 1, medias 2, duples 3. Gana la pareja con los mejores
  pares si el lance quedó en paso o sin disputa; la de los mejores pares, que
  además cobra lo envidado, si se quiso; la que hizo el último envite si no se
  quiso.
- **R-REC-4.** **Juego.** Igual que los pares, con 3 tantos por la 31 y 2 por
  cualquier otro juego, para cada jugador de la pareja ganadora que tiene
  juego.
- **R-REC-5.** **Punto.** En paso: 1 tanto para el mejor punto. Querido: lo
  envidado más 1. No querido: 1 para la pareja que hizo el último envite,
  además de lo que cobró en el acto.
- **R-REC-6.** Los tantos se suman lance a lance; la primera pareja que llega
  al objetivo gana la partida y los lances siguientes ya no se cuentan.

## 8. Final de la partida

- **R-FIN-1.** Gana la primera pareja que llega a **40 tantos** (o a 30, si se
  eligió).
- **R-FIN-2.** Los tantos de un "no quiero" se apuntan en el acto: si con ellos
  una pareja llega al objetivo, la partida acaba en ese momento.
- **R-FIN-3.** En un órdago querido se enseñan las cartas en el acto y la
  pareja que gana ese lance (con R-LAN-7) gana la partida.
- **R-FIN-4.** Si nadie ha ganado, se reparte otra mano con la mano siguiente
  (R-ORD-3).

## 9. Fuera de la v1

- **31 real** (la 31 con tres sietes y una sota, o con figuras según la zona):
  no vale en ASESMUS, Madrid, Navarra, Aragón ni Galicia.
- **Deje** (tantos extra al rechazar un reenvite, en Madrid): regional.
- **Vacas** (partida de varios juegos, normalmente al mejor de tres): la v1
  juega un juego.
- **Señas**: tendrán su apartado aquí con la lista reglamentaria cuando se
  aborden (#35). Nunca durante el mus corrido.
- **Mus visto** (una carta vista al repartir): no puede pasar en la app.

## 10. Glosario

| Término | Significado |
|---|---|
| Mano | El jugador que habla primero en esa mano; también, cada reparto completo |
| Postre | El que habla el último |
| Lance | Cada una de las partes de la mano: grande, chica, pares, juego o punto |
| Envite / envidar | Apostar tantos en un lance; "envido" son 2 |
| Reenvite / "X más" | Subir un envite |
| Órdago | Apostar el juego entero |
| En paso | Lance en el que nadie envida |
| Sin disputa | Lance que solo una pareja puede jugar |
| Mus corrido | La primera mano de cada juego: la mano rota hasta que alguien corta |
| Par, medias, duples | Dos iguales, tres iguales, dos parejas |
| Juego / punto | Sumar 31 o más / menos de 31 |
| Tanto | Cada punto del marcador |

## 11. Ejemplos de manos

| Id | Variante | Mano A | Mano B | Lance | Gana | Por qué |
|---|---|---|---|---|---|---|
| E-1 | ambas | R R 7 1 | R C C C | Grande | A | Segunda carta: R > C |
| E-2 | 8 reyes | 3 R 7 1 | R R 7 1 | Grande | empate | El 3 es rey: iguales |
| E-3 | 4 reyes | 3 R 7 1 | R R 7 1 | Grande | B | Segunda carta: R > 7 |
| E-4 | ambas | 7 1 1 1 | 6 5 4 1 | Chica | A | De menor a mayor: 1 = 1, luego 1 < 4 |
| E-5 | ambas | R 1 1 1 | 4 1 1 1 | Chica | B | 1, 1 y 1 iguales; luego 4 < R |
| E-6 | 8 reyes | 2 1 4 5 | 1 1 4 5 | Chica | empate | El 2 es as: iguales |
| E-7 | ambas | R R 7 1 | C C S S | Pares | B | Duples > par |
| E-8 | ambas | 7 7 7 1 | R R C 1 | Pares | A | Medias > par |
| E-9 | ambas | R R 1 1 | C C S S | Pares | A | Duples: primera pareja R > C |
| E-10 | ambas | R R R R | R R C C | Pares | A | Cuatro reyes = duples R-R; segunda pareja R > C |
| E-11 | ambas | 5 5 R 1 | 5 5 C 1 | Pares | empate | El par es igual; las demás cartas no desempatan |
| E-12 | 8 reyes | 3 3 7 1 | R R 7 1 | Pares | empate | Par de reyes en las dos |
| E-13 | ambas | R C 7 4 (31) | R R R S (40) | Juego | A | 31 es el mejor juego |
| E-14 | ambas | R R 7 5 (32) | R R R S (40) | Juego | A | 32 > 40 |
| E-15 | ambas | R R R 7 (37) | R R 7 6 (33) | Juego | A | 37 > 33 |
| E-16 | 8 reyes | R R 3 1 | — | Juego | — | 10 + 10 + 10 + 1 = 31: tiene juego |
| E-17 | 4 reyes | R R 3 1 | — | Juego | — | 10 + 10 + 3 + 1 = 24: no tiene juego, va al punto |
| E-18 | 4 reyes | R R 7 3 (30) | R R 5 4 (29) | Punto | A | Suma más alta |

## 12. Manos completas

Marcador antes de la mano 0–0, objetivo 40, salvo que se diga otra cosa.
"A" y "B" son las parejas; A es la de la mano.

- **S-1.** Grande en paso; la mejor grande es de B → B +1 en el recuento.
- **S-2.** Grande: A envida 2, B quiere; la mejor grande es de A → A +2.
- **S-3.** Grande: A envida 2, B "5 más", A no quiere → B +2 en el acto.
- **S-4.** Grande: A envida 2, B "5 más", A "10 más", B no quiere → A +7 en
  el acto.
- **S-5.** Pares: A tiene par (un jugador) y medias (su compañero); B tiene
  duples. A envida 2 y B no quiere → A +1 en el acto y, en el recuento, A +3
  (1 del par + 2 de las medias), aunque los duples de B eran mejores.
- **S-6.** Pares sin disputa: solo A tiene pares (medias y par) → A +3 en el
  recuento.
- **S-7.** Juego: A envida 2, B quiere; A tiene 31 y 33, B tiene 32; la 31 de
  A gana → A +2 +3 +2 = +7.
- **S-8.** Punto en paso → +1 para el mejor punto; punto con envite de 2
  querido → +3.
- **S-9.** Órdago a la grande querido; la mano (A) y el segundo en hablar (B)
  tienen R R 7 1, las otras dos manos son peores: empate, gana el más cercano
  a la mano → A gana la partida.
- **S-10.** Marcador A 38 – B 36. Grande en paso para B (37); chica querida a
  2 para A (40): A gana la partida y pares y juego no se cuentan, aunque B
  los fuera a ganar.
- **S-11.** Marcador A 20 – B 39. A envida a la grande y B "5 más"; A no
  quiere → B +2 en el acto, llega a 41 y gana la partida sin seguir la mano.
- **S-12.** Mus corrido: en la primera mano del juego los cuatro dicen mus
  dos veces; la mano ha rotado dos puestos. El postre de ese momento corta el
  mus → pasa a ser la mano y los lances empiezan por él.

## 13. Fallos del motor heredado

Cada uno queda cubierto por un test de la regla que incumple:

| Fallo | Regla | Ejemplo |
|---|---|---|
| La chica se compara como la inversa de la grande | R-LAN-3 | E-4 |
| "No quiero" da siempre 1 tanto | R-ENV-6 | S-3, S-4 |
| Si el postre no tiene pares o juego, los pasos dan la vuelta sin fin | R-ENV-2 | — |
| Quien gana pares, juego o punto con un "no quiero" no cobra sus jugadas | R-REC-3 a R-REC-5 | S-5 |
| Los pares se cuentan con quien podía jugar el lance en curso | R-REC-3 | — |
| Al agotarse el mazo se crea una baraja nueva (cartas duplicadas) | R-MUS-4 | — |
| La partida acaba siempre a 40 y el recuento no para al llegar | R-FIN-1, R-REC-6 | S-10 |
| Un "no quiero" que llega a 40 no acaba la partida | R-FIN-2 | S-11 |
| Un órdago empatado lo gana siempre la pareja rival | R-FIN-3 | S-9 |
| No hay mus corrido | R-MUS-5 | S-12 |

## Fuentes

[ASESMUS](https://www.asesmus.com/wp-content/uploads/2018/08/Reglamento_asesmus_v1.01.pdf),
[Barcelona Mus Club](https://barcelonamus.com/club/reglamento),
[Asociación Navarra de Mus](https://musnavarra.com/reglamento/reglamento-de-juego/),
[Bizkaia](https://www.asesmus.com/wp-content/uploads/2022/06/RegMusBIZKAIA.pdf),
[pagat.com](https://www.pagat.com/vying/mus.html).
