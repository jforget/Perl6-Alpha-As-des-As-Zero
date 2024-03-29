# INTRODUCTION

Les programmes de jeu pour l'As des As se basent sur une table
de transition (page de départ, manœuvre) → page d'arrivée,
stockée dans un fichier JSON. _Handy Rotary_ comporte 25 manœuvres par page.
Recopier un livret avec 222 pages et 25 manœuvres dans un fichier JSON, soit 5550 entrées,
est fastidieux, donc sujet à erreur. Et il faut le faire pour au moins
deux livrets. Même dans le cas de _Wingleader_, qui a seulement 13 manœuvres
par page, cela ferait 2886 entrées à taper pour chaque livret.

Heureusement, les différentes pages correspondent au positionnement d'un
avion sur une grille de 37 hexagones avec 6 orientations possibles.
En se basant sur cette géométrie sous-jacente, il est possible
de saisir un sous-ensemble représentatif
de transitions (page de départ, manœuvre) → page d'arrivée
et d'obtenir toutes les autres par calcul et par déduction.

De plus, tous les jeux de la série utilisent la même grille de 37 hexagones
avec la même numérotation. Donc, il suffit de déterminer une bonne
fois pour toutes les numéros de page des hexagones et tous les livrets
peuvent être alors générés en décrivant les 13 à 26 manœuvres disponibles
(plus la table des tirs, qu'il est difficile d'automatiser).

J'ai ainsi reconstitué la grille hexagonale en me basant sur le
livret FW190 de _Wingleader_, puis j'ai généré le fichier JSON
pour le Sopwith Camel et le Fokker DR1 de _Handy Rotary_,
pour le P-51 et le FW190 de _Wingleader_ (à titre de vérification)
et pour un jeu similaire mettant en scène un épervier aux prises
avec un drone de loisir.

# ÉPERVIER CONTRE DRONE DE LOISIR

Pour des raisons de copyright, je ne peux pas diffuser sur Github
les fichiers JSON du Camel, du DR1, du Mustang ou du FW. Le brevet
sur le mécanisme du jeu a expiré, mais le copyright sur _Handy Rotary_
et sur _Wingleader_ est toujours actif. J'ai donc créé un jeu
« épervier contre drone de loisir » en me basant sur des
anecdotes récentes racontant les rencontres brutales entre des oiseaux
de proie et des drones de loisir. Le but du drone est de filmer l'épervier,
tandis que le but de l'épervier est de détruire le drone.

Alors que la plupart des animaux et des véhicules sur terre ont une
orientation avant / arrière, le drone, de type quadrocopter, n'a pas
d'orientation précise pour ses déplacements, semblable aux méduses et
aux anémones de mer. Il peut aussi facilement aller en avant qu'en
arrière ou de côté. Il a quand même un avant et un arrière, car je
suppose que la caméra est fixe et immobile par rapport au chassis du
drone. Ainsi, l'avant du drone correspond au champ visuel de sa
caméra.

Je ne prétend pas que ce jeu soit très intéressant, surtout
qu'il n'y a pas les dessins qui sont l'un des points forts
de l'_As des As_. Je ne prétend pas non plus qu'il soit
équilibré. Mais ce jeu est ma création, donc
je peux le diffuser sur Github à ma guise, avec la licence libre
qui me plaît.

Donc dans la suite, je présente la préparation comme si je m'étais basé
sur un livret « drone » existant au lieu du livret FW190.

# ÉTAPES

## Saisie

Sous éditeur de texte, écrire un fichier `Drone-init.json`.
Ce fichier contient la description des manœuvres du drone, ainsi que les
pages où le drone peut « tirer » sur l'épervier (c'est-à-dire le filmer). Le fichier ne contient aucune
transition (page de départ, manœuvre) → page d'arrivée.

## Initialisation

Le programme `init.p6` commence par vider le contenu de la base `aoa_prep` dans MongoDB.

Ensuite, il recopie le fichier `Drone-init.json` dans
une collection `Manoeuvres` de la base MongoDB. Il initialise une autre
collection `Pages` avec deux pages : la page 223, puisqu'elle a un statut
spécial, et la page 187 qui est une page normale.

Le choix de la page 187 est en partie arbitraire. C'est la page qui correspond
à la situation où les deux joueurs sont l'un au-dessus de l'autre dans le
même hexagone et avec le même cap. Mais j'aurais très bien pu choisir
une autre page initiale.

## Mise à jour incrémentale

Le programme `maj.p6` est un programme en ligne de commande
qui reçoit comme paramètres un numéro de page de départ
et la liste des transitions manœuvre → page d'arrivée
pour cette page. Par exemple la première fois qu'on l'exécutera,
ce sera forcément avec la page 187, donc la ligne de commande sera :

    perl6 maj.p6 --page=187 -a=205 -b=187 -c=198 -d=3 -e=15 -f=16 -g=2 -h=17 -i=1

Le programme met à jour les
transitions (page de départ, manœuvre) → page d'arrivée.
Si la ligne de commande mentionne des pages d'arrivée que l'on n'avait pas
encore rencontrées jusqu'à présent, le programme détermine où se situent
ces pages dans la grille hexagonale et quelle est l'orientation de
l'avion (ou du drone, ou de l'oiseau, etc).

En outre, le programme applique chaque manœuvre à chacune des
nouvelles pages. Si le résultat est une page déjà identifiée, le programme
renseigne cette transition (page de départ, manœuvre) → page d'arrivée
dans la base de données. Si le résultat n'est pas connu, le programme laisse
tomber cette transition pour l'instant.

Également, le programme applique les manœuvres
« à rebrousse-poil » pour déterminer les
transitions (page de départ, manœuvre) → page d'arrivée
dans laquelle la page d'arrivée est la nouvelle page et la page
de départ est une page déjà ajoutée précédemment.

Cette recherche « à rebrousse-poil » n'existait pas dans
la version de mars 2018, je l'ai ajoutée en juin 2018. À la place,
j'avais un paramètre « recalcul complet » qui passait en
revue _toutes_ les pages, les anciennes comme les nouvelles
et qui déterminait pour chaque manœuvre la page d'arrivée.
Très chronophage.

### Exemple

Prenons un engin avec très peu de manœuvres disponibles.
La manœuvre A, qui permet un déplacement en crabe vers l'hexagone
voisin à 10 heures, la manœuvre B qui fait avancer dans l'hexagone
juste devant la position initiale et la manœuvre C qui permet un
déplacement en crabe vers l'hexagone voisin à 2 heures.

![Représentation des mouvements possible sur la grille hexagonale](hexagons-a-fr.png)

_Copie d'écran personnelle. Les conditions de licence sont les mêmes que pour le texte._

Suite à `init.p6`, la seule page connue est la page 187 (outre la
page 223 dont le statut est spécial). Le premier appel de `maj.p6`
est donc :

    perl6 maj.p6 -page=187 -a=15 -b=16 -c=17

Le programme met à jour les enchaînements avec :

    (187, A) → 15
    (187, B) → 16
    (187, C) → 17

Et la carte est complétée avec :

![Représentation sur la grille hexagonale des pages accessibles depuis la page 187](hexagons-b.png)

_Copie d'écran personnelle. Les conditions de licence sont les mêmes que pour le texte._

En examinant les pages nouvellement créées 15, 16 et 17 et en leur appliquant
les manœuvres A, B et C, le programme constate que sur les 9 tentatives, deux
réussissent. Par conséquent, il ajoute les enchaînements

    ( 15, C) → 16
    ( 17, A) → 16

Le deuxième appel à `maj.p6` s'applique à la page 16 :

    perl6 maj.p6 -page=16  -a=46 -b=91 -c=107

Le programme met à jour les enchaînements avec :

    ( 16, A) →  46
    ( 16, B) →  91
    ( 16, C) → 107

Et la carte est complétée avec :

![Remplissage de la grille hexagonale après la deuxième mise à jour](hexagons-c.png)

_Copie d'écran personnelle. Les conditions de licence sont les mêmes que pour le texte._

En examinant les pages nouvellement créées 46, 91 et 107 et en leur appliquant
les manœuvres A, B et C, le programme
ajoute les enchaînements

    ( 46, C) → 91
    (107, A) → 91

Le programme applique également les manœuvres A, B et C à rebrousse-poil
sur les pages 46, 91 et 107. On retrouve certains enchaînements déjà créés :

    (x, A) →  46 avec x =  16
    (x, A) →  91 avec x = 107
    (x, B) →  91 avec x =  16
    (x, C) →  91 avec x =  46
    (x, C) → 107 avec x =  16

il y a quelques échecs :

    (x, C) →  46
    (x, A) → 107

mais également quelques réussites :

    (x, B) →  46 avec x = 15
    (x, B) → 107 avec x = 17

ce qui permet d'ajouter les enregistrements :

    ( 15, B) →  46
    ( 17, B) → 107

### Itérations

Le programme `maj.p6` est appelé autant de fois qu'il le faut pour
que toutes les transitions soient connues pour toutes les pages
et toutes les manœuvres. Tous ces appels sont accumulés dans le
script shell `maj1`, de sorte que l'on peut refaire la totalité
des itérations en un seul appel de `maj1`.

Avec 9 manœuvres, dont une (`B`) qui consiste à faire du sur-place,
il faut au moins 28 itérations pour définir toutes les pages.
Compte tenu des recouvrements inévitables, il a fallu 48 appels
de `maj.p6` pour définir toutes les pages. Il y avait peut-être
plus rapide, mais pas tellement plus rapide.

## Affichage

Le programme `aff.p6` affiche le contenu de la base de données
sous la forme d'un tableau HTML. Il y a également une grille hexagonale
en _ASCII art_, présentant les positions du drone pour toutes les pages connues.
L'épervier se trouve au centre de la grille et se dirige vers le haut, tandis
que le drone est n'importe où dans la grille et dans n'importe quelle direction.
Cela me sert lors du processus
itératif à choisir quelle page je vais utiliser lors du prochain appel
de `maj.p6` (ou des deux prochains appels, ou des trois, ou...). Inutile de saisir une
page pour laquelle on connaît déjà les deux tiers des enchaînements
s'il en existe pour lesquelles on n'en connaît qu'un ou deux.

Voici deux exemples, le premier
[après la première mise à jour](https://github.com/jforget/Perl6-Alpha-As-des-As-Zero/blob/master/Preparation/etape1.pod)
et le second une fois
[la grille terminée](https://github.com/jforget/Perl6-Alpha-As-des-As-Zero/blob/master/Preparation/etape-finale.pod).
À noter que l'affichage se fait en couleurs, mais que Github ne reprend pas ces couleurs.

## Génération du livret

Le processus itératif se termine lorsque toutes les pages
ont été citées au moins une fois lors des appels à `maj.p6`
et donc quand on connaît la position de toutes les pages.

On peut alors générer un livret pour n'importe quel objet volant
ou n'importe quelle créature volante. Le programme `livret.p6`
lit en entrée un fichier `Epervier-init.json` de taille réduite
et produit un fichier complet `Epervier.json` et un fichier
`Epervier.html` qui contiennent la totalité des
transitions (page de départ, manœuvre) → page d'arrivée.

# FONCTIONNEMENT INTERNE

## La Classe `Depl.pm6`

Une question centrale pour les programmes de préparation, c'est comment
représenter la position relative de deux avions, qu'il s'agisse de la position
du drone par rapport à l'épervier ou qu'il s'agisse de la position finale
du drone par rapport à sa position initiale, suite à l'exécution d'une
manœuvre. Pour cela, j'ai créé une classe `Depl.pm6`, pour « déplacement ».
Il s'agit soit du déplacement entraîné par l'exécution d'une manœuvre, soit
du déplacement virtuel que le drone aurait effectué, en une ou plusieurs fois,
pour aller de la position de l'épervier jusqu'à la position qu'il occupe.

### Repérage des hexagones

Pour définir cette classe, il faut d'abord commencer par définir comment on
peut repérer les 37 hexagones de la grille. Pour la différence de caps, on
verra après. Du coup, dans ce paragraphe, j'assimile la notion de page avec
la notion d'hexagone.

Au début, j'ai envisagé d'utiliser un système de coordonnées cartésiennes avec
un repère orthonormé.

![Représentation de la grille hexagonale dans un repère orthonormé](hexagons-on.png)

_Copie d'écran personnelle. Les conditions de licence sont les mêmes que pour le texte._

    .                       --------
    .                      /        \               Numéro     X         Y
    .              --------    16    --------            2     0        -1
    .             /        \        /        \           3    -0.866    -0.5
    .            (    15    --------    17    )          1     0.866    -0.5
    .             \        /        \        /         187     0         0
    .              --------   187    --------           15    -0.866     0.5
    .             /        \        /        \          17     0.866     0.5
    .            (     3    --------     1    )         16     0         1
    .             \        /        \        /
    .              --------    2     --------
    .                      \        /
    .                       --------

Puis un repère orthogonal sans être normé

![Représentation de la grille hexagonale dans un repère orthogonal](hexagons-o.png)

_Copie d'écran personnelle. Les conditions de licence sont les mêmes que pour le texte._

    .                       --------
    .                      /        \               Numéro     X         Y
    .              --------    16    --------            2     0        -1
    .             /        \        /        \           3    -1        -0.5
    .            (    15    --------    17    )          1     1        -0.5
    .             \        /        \        /         187     0         0
    .              --------   187    --------           15    -1         0.5
    .             /        \        /        \          17     1         0.5
    .            (     3    --------     1    )         16     0         1
    .             \        /        \        /
    .              --------    2     --------
    .                      \        /
    .                       --------

Ou un repère normé sans être orthogonal (l'axe des X est incliné, tandis que
l'axe des Y est, comme à l'accoutumée, vertical). Ne rigolez pas, certains
jeux d'Avalon Hill utilisent un tel système de coordonnées.
[Suivez mon regard](https://boardgamegeek.com/boardgame/1711/richthofens-war).

![Représentation de la grille hexagonale dans un repère normé](hexagons-n.png)

_Copie d'écran personnelle. Les conditions de licence sont les mêmes que pour le texte._

    .                       --------
    .                      /        \               Numéro     X         Y
    .              --------    16    --------            2     0        -1
    .             /        \        /        \           1     1        -1
    .            (    15    --------    17    )          3    -1         0
    .             \        /        \        /         187     0         0
    .              --------   187    --------           17     1         0
    .             /        \        /        \          15    -1         1
    .            (     3    --------     1    )         16     0         1
    .             \        /        \        /
    .              --------    2     --------
    .                      \        /
    .                       --------

Les coordonnées polaires semblent offrir plus de promesses. D'ailleurs, c'était utilisé
par les pilotes de la Seconde Guerre Mondiale avec le système du cadran d'horloge.

    .                       --------
    .                      /        \               Numéro     R      angle
    .              --------    16    --------          187     0      indéfini
    .             /        \        /        \          16     1        12h
    .            (    15    --------    17    )         17     1         2h
    .             \        /        \        /           1     1         4h
    .              --------   187    --------            2     1         6h
    .             /        \        /        \           3     1         8h
    .            (     3    --------     1    )         15     1        10h
    .             \        /        \        /
    .              --------    2     --------
    .                      \        /
    .                       --------

Pour simplifier, j'ai utilisé des incréments de 60 degrés orientés dans le sens des aiguilles
d'une montre avec une plage de 0 à 5. Cela correspond à la moitié de l'angle du cadran d'horloge,
sachant que 12h est converti en **0** au lieu de **6**.

Pour la première couronne, c'est bien beau, mais on commence à avoir des problèmes
avec la deuxième couronne, les rayons ne sont plus entiers, même si les angles sont
encore des angles simples, multiples de 30°.

    .                       --------
    .                      /        \               Numéro     R      angle
    .              --------    91    --------          187     0      indéfini
    .             /        \        /        \          16     1        12h    0°
    .     --------   118    --------   107    )         17     1         2h   60°
    .    /        \        /        \        /           1     1         4h  120°
    .   (    54    --------    16    --------            2     1         6h  180°
    .    \        /        \        /        \           3     1         8h  240°
    .     --------    15    --------    17    )         15     1        10h  300°
    .    /        \        /        \        /          54     2        10h  300°
    .   (    76    --------   187    --------           76     1,732     9h  270°
    .    \        /        \        /        \          91     2         0h  240°
    .     --------     3    --------     1    )        107     1,732     1h   30°
    .             \        /        \        /         118     1,732    11h  330°
    .              --------    2     --------
    .                      \        /
    .                       --------

Pour avoir des valeurs plus simples à utiliser, on considère que le déplacement
ne se fait pas en ligne droite, mais pas à pas en passant par des hexagones intermédiaires,
quitte à zigzaguer un peu. On représente ainsi un chemin par une suite de
directions `0` à `5`, la longueur de chaque pas étant implicitement de 1.
Voici par exemple les chemins depuis l'hexagone 187 :

    .                       --------
    .                      /        \               Numéro     chemin
    .              --------    91    --------          187     (rien)
    .             /        \        /        \          16     0
    .     --------   118    --------   107    )         17     1
    .    /        \        /        \        /           1     2
    .   (    54    --------    16    --------            2     3
    .    \        /        \        /        \           3     4
    .     --------    15    --------    17    )         15     5
    .    /        \        /        \        /          54     55
    .   (    76    --------   187    --------           76     45
    .    \        /        \        /        \          91     00
    .     --------     3    --------     1    )        107     01
    .             \        /        \        /         118     05
    .              --------    2     --------
    .                      \        /
    .                       --------

Et l'on retrouve une géométrie à laquelle les wargameurs sont habitués,
qui indique que de l'hexagone 187 jusqu'à l'hexagone 76, la distance
est 2 et non pas 1,732.

Dans tout cela, je n'ai pas tenu compte de la différence de cap entre
les deux avions. On utilise la même notation de `0` à `5`, mais sans
les mélanger avec le chemin.
Ainsi, si les deux avions sont parallèles comme dans la page 1 de l'exemple,
leur différence de cap sera `0`. Mais dans la page 8, la différence
de cap de l'Allemand relativement à l'Anglais est `5`.

### Représentation interne

La classe utilise deux représentations pour un déplacement, la
représentation en chaîne de caractères et la représentation numérique.
La représentation en chaîne de caractères énumère les directions de
déplacement depuis la position de l'épervier (ou de l'avion anglais) pour arriver à la
position du drone (ou de l'avion allemand), ajoute un point-virgule et termine
avec l'écart de caps entre les deux protagonistes. Ainsi, la page 1
est représentée par :

    2;0

Car l'hexagone du drone est situé dans la direction `2` par rapport
à celui de l'épervier et que les deux ont le même cap. La page 8
a pour code :

    2;5

car il s'agit du même hexagone, mais le drone a pivoté de 60 degrés
vers babord. Cette chaîne de caractères est stockée dans l'attribut `$.chemin`.

La représentation numérique comporte un tableau `@.avance` et un scalaire `$.virage`
Le scalaire `$.virage` reprend l'écart de caps entre les deux avions. Le tableau `@.avance`
compte le nombre de pas dans les directions `0` à `5`. Exemples :

    page         1     8     42     48     96     159
    $.chemin     2;0   2;5   00;1   33;1   33;0   112;1
    @.avance[0]  0     0     2      0      0      0
    @.avance[1]  0     0     0      0      0      2
    @.avance[2]  1     1     0      0      0      1
    @.avance[3]  0     0     0      2      2      0
    @.avance[4]  0     0     0      0      0      0
    @.avance[5]  0     0     0      0      0      0
    $.virage     0     5     1      1      0      1

### Cas particuliers

Il existe 6 pages représentant les deux avions dans le même hexagone, l'un au-dessus
de l'autre (la seule intervention de l'altitude dans le jeu d'introduction). Dans ce
cas, toutes les valeurs de `@.avance` sont à zéro et le contenu de `$.chemin` commence
par un point-virgule. Ainsi, la page 187 représente les avions dans le même hexagone
avec le même cap, donc `$.chemin` contient « `;0` ». Page 188, les deux avions sont
aussi dans le même hexagone, mais dans des directions opposées. `$.chemin` contient
alors « `;3` ».

### Normalisation

Comme cela a déjà été signalé, le chemin utilisé doit être le chemin le plus court
possible. Cela dit, en reprenant l'exemple de la page 150, le chemin de 187 vers 150 peut être
`112;1`, mais aussi `121;1` ou `211;1`. Comme la valeur sert de clé de recherche dans les
programmes, il faut que l'on se mette d'accord sur une valeur normalisée. On prend le
chemin dans lequel les pas élémentaires sont dans l'ordre croissant. C'est-à-dire
`112;1` dans le cas de la page 150.

Cette problématique ne concerne pas la représentation numérique.

Une autre problématique concerne les deux représentations. Il se peut que l'on obtienne
un chemin plus long que le chemin minimal, par exemple à la suite d'un calcul.
Ainsi, le chemin `13;0` est équivalent au chemin `2;0`. Il faut donc ajuster le
chemin courant jusqu'à obtenir la version équivalente la plus courte. Pour ce faire,
il suffit d'appliquer deux mécanismes.

Si le chemin contient des pas avec un écart de 180°, par exemple `0` avec `3`, ou `1` avec `4`,
alors ces pas élémentaires s'éliminent deux à deux. Par exemple, `1244;5` devient `24;5`, le `1`
ayant éliminé l'un des deux `4`.

L'autre cas est celui où le chemin contient des pas écartés de 120°. Alors on remplace ces pas
par leur bissectrice. Voir l'exemple déjà cité, où `13;0` devient `2;0`, ou la suite de l'exemple
précédent où `24;5` devient `3;5`. Ou bien, plus complexe,
`1123;3` devient `122;3` en remplaçant `13` par `2`. Ou encore, `135;1` devient `25;1`, auquel on applique de nouveau la première
règle de normalisation, ce qui donne un chemin vide `;1`. Remarquez que si l'on avait normalisé en
associant le `3` et le `5` pour les remplacer par `4`, cela aurait donné un chemin `14;1` qui, lui aussi, aurait donné
dans un deuxième temps le chemin vide `;1`.

# LICENCE

Texte diffusé sous la licence CC-BY-NC-ND : Creative Commons avec clause de paternité, excluant l'utilisation commerciale et excluant la modification.
