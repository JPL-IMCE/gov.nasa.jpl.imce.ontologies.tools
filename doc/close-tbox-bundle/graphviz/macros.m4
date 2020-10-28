define(`sub', `$1<SUB>$2</SUB>')
define(`italic', <I>$1</I>)

define(`UNION', $1&cup;$2)
define(`INTERSECTION', $1&cap;$2)
define(`DIFFERENCE', $1\\$2)

define(`Ai1', sub(A, italic(i)``,1''))
define(`Ai2', sub(A, italic(i)``,2''))
define(`Aij', sub(A, italic(i)``,''italic(j)))

define(`B1', sub(B, 1))
define(`B2', sub(B, 2))
define(`Bi', sub(B, italic(i)))
define(`Bn', sub(B, italic(k)))

define(`D1', sub(D, 1))
define(`D2', sub(D, 2))
define(`Dl', sub(D, italic(l)))

define(`Ei1', sub(E, ``i,1''))
define(`Ei2', sub(E, ``i,2''))
define(`Eim', sub(E, ``i,''italic(m)))

define(`BiMC', DIFFERENCE(Bi, C))
define(`BiIC', INTERSECTION(Bi, C))

