
import           Data.List (lookup)
import           Data.Char (chr, ord)

type Linie = Int
type Coloana = Char
type Pozitie = (Coloana, Linie)

type DeltaLinie = Int
type DeltaColoana = Int
type Mutare = (DeltaColoana,DeltaLinie)

ex1t1, ex1t2, ex1t3 :: Bool
ex1t1 = mutaDacaValid ('e', 5) (1, -2) == ('f', 3)
     -- deoarece 'f' este o casuță la dreapta lui 'e', linia 3 e cu 2 sub 5
ex1t2 = mutaDacaValid ('b', 5) (-2, 1) == ('b', 5)
     -- deoarece mutând 2 căsuțe la stânga am ieși de pe tablă
ex1t3 = mutaDacaValid ('e', 2) (1, -2) == ('e', 2)
     -- deoarece mutând 2 căsuțe în jos am ieși de pe tablă

-- Exercitiul 1
mutaDacaValid :: Pozitie -> Mutare -> Pozitie
mutaDacaValid = undefined

mutariPosibile :: [Mutare]
mutariPosibile = [(-2,-1),(-2,1),(2,-1),(2,1),(-1,-2),(1,-2),(-1,2),(1,2)]

type IndexMutare = Int

type Joc = [IndexMutare]
 
exJoc :: Joc
exJoc = [0,3,2,7]

type DesfasurareJoc = [Pozitie]

ex2t1, ex2t2, ex2t3 :: Bool
ex2t1 = joaca ('e',5) [0,3,2,7] == [('e',5),('c',4),('e',5),('g',4),('h',6)]
ex2t2 = joaca ('e',5) [0,3,9,2,7] == [('e',5),('c',4),('e',5),('g',4),('h',6)]
     -- deoarece 9 nu e un index valid in mutariPosibile
ex2t3 = joaca ('a',8) [0,3,2,7] == [('a',8),('c',7)]
     -- deoarece doar mutarea dată de indicele 2 poate fi efectuată

-- Exercitiul 2
joaca :: Pozitie -> Joc -> DesfasurareJoc
joaca = undefined

data ArboreJoc = Nod Pozitie [ArboreJoc]
  deriving (Show, Eq)

parcurge :: Int -> ArboreJoc -> ArboreJoc
parcurge adancime (Nod p as)
  | adancime <= 0 = Nod p []
  | otherwise     = Nod p (map (parcurge (adancime - 1)) as)

ex3t1, ex3t2, ex3t3 :: Bool
ex3t1 = -- generez arborele de joc pentru ('e',5) pana la adâncimea 1
    parcurge 1 (genereaza ('e', 5))
    == Nod ('e',5) -- poziția inițială
          [ Nod ('c',4) []
          , Nod ('c',6) []
          , Nod ('g',4) []
          , Nod ('g',6) []
          , Nod ('d',3) []
          , Nod ('f',3) []
          , Nod ('d',7) []
          , Nod ('f',7) []
          ] -- cele 8 poziții la care pot ajunge într-o mutare
ex3t2 = -- generez arborele de joc pentru ('a',1) pana la adâncimea 1
    parcurge 1 (genereaza ('a', 1))
    == Nod ('a',1) [Nod ('c',2) [],Nod ('b',3) []] 
ex3t3 = -- generez arborele de joc pentru ('a',1) pana la adâncimea 2
    parcurge 2 (genereaza ('a', 1))
    == Nod ('a',1)
          [ Nod ('c',2)   -- nivelul I
              [ Nod ('a',3) [] -- nivelul II cu nivelul III vid
              , Nod ('e',1) []
              , Nod ('e',3) []
              , Nod ('b',4) []
              , Nod ('d',4) []
              ]
          , Nod ('b',3)   -- nivelul I
              [ Nod ('d',2) []
              , Nod ('d',4) [] -- d4 apare din nou, dar pe altă cale, e OK
              , Nod ('c',1) []
              , Nod ('a',5) []
              , Nod ('c',5) []
              ]
          ]

-- Exercitiul 3
genereaza :: Pozitie -> ArboreJoc
genereaza = undefined

newtype JocWriter a = Writer { runWriter :: (a, Joc) }

scrie :: IndexMutare -> JocWriter ()
scrie i = Writer ((), [i])

instance Monad JocWriter where
  return a = Writer (a, [])
  ma >>= k =    let (x, jocM) = runWriter ma
                    (y, jocK) = runWriter (k x)
                in  Writer (y, jocM ++ jocK)

instance Functor JocWriter where
  fmap f ma = ma >>= return . f

instance Applicative JocWriter where
  pure = return
  mf <*> ma = mf >>= (<$> ma)

ex4t1, ex4t2, ex4t3 :: Bool
ex4t1 =
      runWriter (joacaBine ('e',5) [0,3,2,7])
      ==  ( [('e',5),('c',4),('e',3),('f',5)]
          , [0,2,7]
          ) -- mutarea 3 nu mai e valida pentru ca revine la o pozitie veche
ex4t2 =
      runWriter (joacaBine ('e',5) [0,3,9,2,7])
      ==  ( [('e',5),('c',4),('e',3),('f',5)]
          , [0,2,7]
          ) -- indicele 9 e in afara tabelei de mutari valide
ex4t3 = runWriter (joacaBine ('a',8) [0,3,2,7]) == ([('a',8),('c',7)], [2])
     -- deoarece doar mutarea dată de indicele 2 poate fi efectuată

-- Exercitiul 4
joacaBine :: Pozitie -> Joc -> JocWriter DesfasurareJoc
joacaBine = undefined

exst1, exst2, exst3 :: Bool
exst1 = gasesteMutare  ('e', 5) ('f', 3) == Just 5
exst2 = gasesteMutare  ('a', 8) ('c', 7) == Just 2
exst3 = gasesteMutare  ('e', 5) ('f', 6) == Nothing

-- Exercitiul suplimentar
gasesteMutare :: Pozitie -> Pozitie -> Maybe IndexMutare
gasesteMutare = undefined

