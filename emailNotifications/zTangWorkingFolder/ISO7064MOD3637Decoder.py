#This is a Python3 implementation of ISO 7064 Mod 37,36
#by Richard Gooch
#This is implemented by way of example for the GRid Code (using an example e.g. A12425GABC1234002-x where x is the check digit (a1) that we want to find)
#The layout for this would be
#
# |A  |1  |2  |4  |2  |5  |G  |A  |B  |C  |1  |2  |3  |4  |0  |0  |2  |x  |
# |a18|a17|a16|a15|a14|a13|a12|a11|a10|a0 |a8 |a7 |a6 |a5 |a4 |a3 |a2 |a1 |


# this python dictionary sets out the ISO 7064 character encoding table so we can assign values to the characters of the identifier string
char_to_value = {'0':0,
              '1':1,
              '2':2,
              '3':3,
              '4':4,
              '5':5,
              '6':6,
              '7':7,
              '8':8,
              '9':9,
              'A':10,
              'B':11,
              'C':12,
              'D':13,
              'E':14,
              'F':15,
              'G':16,
              'H':17,
              'I':18,
              'J':19,
              'K':20,
              'L':21,
              'M':22,
              'N':23,
              'O':24,
              'P':25,
              'Q':26,
              'R':27,
              'S':28,
              'T':29,
              'U':30,
              'V':31,
              'W':32,
              'X':33,
              'Y':34,
              'Z':35
              }

# this python dictionary sets out the inverse of the ISO 7064 character encoding table so we can look up the check character according to the algo's output
value_to_char = {0:'0',
              1:'1',
              2:'2',
              3:'3',
              4:'4',
              5:'5',
              6:'6',
              7:'7',
              8:'8',
              9:'9',
              10:'A',
              11:'B',
              12:'C',
              13:'D',
              14:'E',
              15:'F',
              16:'G',
              17:'H',
              18:'I',
              19:'J',
              20:'K',
              21:'L',
              22:'M',
              23:'N',
              24:'O',
              25:'P',
              26:'Q',
              27:'R',
              28:'S',
              29:'T',
              30:'U',
              31:'V',
              32:'W',
              33:'X',
              34:'Y',
              35:'Z'
              }


#The ISO algo
def iso_7064_mod_37_36(grid):
    length = len(grid) #TBD, check and error out if the wrong length of code is entered (should be 17 chars here, i.e. less the actual check digit and without any hyphens, whitespace etc)

    grid_list = list(grid) #not part of the core algo, we are just splitting the string into a list of chars for processing step by step...

    Pj=36 #initial value P1 is the Modulo, i.e. 36, as defined by ISO 7064 Mod 37, 36

    #iterate through the 17 GRid identifier chars from a18 to a2 (TBD any error checking for bad chars)
    for char in grid_list:
        value = char_to_value[char] #The ISO algo calls this "a(n-j+1)" which would be a(18-j+1), i.e. first time around a(18-1+1) = a(18)
        Sj = (Pj%37) + value
        Sjmod36 = Sj%36
        if(Sjmod36==0): #zero is not allowed here
            Sjmod36=36
        Pj = Sjmod36 * 2

    #last step, find the check digit, a1, shown here as 'x'...
    x = 37-Pj%37
    if(x==36): #36 is not allowed here
        x=0
    chk_chr = value_to_char[x] #'x' is a value, we need to look up the corresponding character...
    return(chk_chr)


#try some test GRids to exercise the code
grid = "A12425GABC1234000" #Q
chk = iso_7064_mod_37_36(grid) 
print(grid, "-", chk)
