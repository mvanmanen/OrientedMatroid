from typing import List,Tuple
import scipy.spatial
import numpy as np
# points=[
# [1,0,0,0],
# [1,0,0,1],
# [1,0,1,0],
# [1,1,0,0],
# ]
# weights=[2,3,4,5]

# the k-th order are the averages of k of the n functions f_i
# but we need to still proof that the corresponding triangulation dual to the 
# k-th order diagram is the one with all spheres that have k-1 points inside

# we have a bunch of validate functions.
# the idea is to define these here, but throw the exceptions in the actual functions


def binary_validate_str(a:str)->bool:
    """Validate the string 

    Parameters
    ----------
    a:str
        A string with only zeros and ones

    Returns
    -------
    bool:
        Returns True if the string is a valid covector cocircuit string
    """
    return(a.replace('1','').replace('0','')=='')

def covector_validate_str(a:str)->bool:
    """Validate the string 

    Parameters
    ----------
    a:str
        A covector in string form

    Returns
    -------
    bool:
        Returns True if the string is a valid covector cocircuit string

    """
    return(a.replace('+','').replace('-','').replace('0','')=='')

def covector_validate_int(a:int,lengte:int)->bool:
    """Validate the integer 

    Parameters
    ----------
    a:int
        A covector in string form
    lengte:int
        The length of the covector

    Returns
    -------
    bool:
        Returns True if the string is a valid covector cocircuit string
    """
    if a<0:
        return(False)
    if a>covector_max_int(lengte):
        return(False)
    return(True)

def covector_max_int(lengte:int)->int:
    """Get the maximum integer for a given length

    Notes
    -----

    For length 1 we expect 2
    Next is 2*3+2
    Next is 2*9+2*3+2
    For length n 2*(3^(n-1)+...+1)
    Which is 3^n-1

    Parameters
    ----------
    lengte:int

    Returns
    -------
    int
    """
    return(3**lengte-1)


def read_qh_points(fl:str)->Tuple:
    """We read in a file with points and weights. 
    The weights are squared radiuses but these can all 
    be 
    """
    bb=[] # first part of the file are the bounding boxes
    hlfspc=[]
    dimension=0 # count the dimension
    readpoints=0 # whether we are reading bounding box or point
    if not os.path.isfile(fl):
        raise RuntimeError(f"read_qh_points: file {fl} does not exist ")
    with open(fl,"r") as f:
        for line in f:
            nos=[float(x) for x in line.split()]
            if len(nos)=2:
                bb.append(nos)
                dimension+=1
                if not nos[1]<nos[2]:
                    raise RuntimeError(f"read_qh_points: at dimension {dimension} an invalid bounding box with lower bound {nos[1]} and upper bound {nos[2]}")
            elif len(nos)<=1:
                raise RuntimeError("read_qh_points: encountered a line with 1 or less coordinates ")
                

def get_qh_points(points:List,weights:List)->List:
    """Change this into a point set that can be used with qhull

    Notes
    -----

    From the points and the weights compute the upper points
    We need to compute half the squared norm and

    Parameters
    ----------
    
    f={x,P}+c
    c=(w-P^2)/2
    y< {x,P}+c is the halfspace
    y-{x,P}-c<0 is the qhull representation
    np.array(1,-P,-c)
    Returns
    -------
    """
    halfnorms=[sum([x*x for x in p])/2 for p in points]
    return(np.vstack[-1*np.array([-1]+p+[q]) for q,p in zip(halfnorms-weights/2,points)])

def get_circuits_from_intersection

def get_halfspace_np(point:np.ndarray,weight:float)->np.ndarray:
    """This should call the halfspace intersection
    The halfspace intersection
    """

    pass
def are_adjacent(vertex1:np.ndarray,np.ndarray)->bool:
    """Find out whether two vertices are adjacent by passing by all halfplanes
    """
    pass
def get_halfspace_list(point:List,weight:float)->np.ndarray:
    """
    If we have a point we get the ha
    <x,p_i> + w_i-
    """
    pass

def covector_get_str(i:int,lengte:int)->str:
    """Returns the covector string

    Notes
    -----
    Note that in python3 all integers are arbitrary size
    So that makes all of this much easier
    That's also how a C implementation would run
    Just use gmp arbitrary size integers.
    It'll be much easier

    Parameters
    ----------
    i:int
        Circuit info
    lengte:int
        The length of the circuit

    Returns
    -------
    str:
        The string representation of the cocircuit or covector
    """
    if i>covector_max_int(lengte):
        raise RuntimeError(f"covector_get_str : the integer {i} is too large for length {lengte}.")
    if i<0:
        raise RuntimeError(f"covector_get_str : the integer {i} is negative and that cannot be.")

    a=i%3
    if lengte>1:
        c=covector_get_str(i//3,lengte-1)
        if a==0:
            return("0"+c)
        elif a==1:
            return("+"+c)
        else:
            return("-"+c)
    else:
        if a==0:
            return("0")
        elif a==1:
            return("+")
        else:
            return("-")

def covector_get_int(a:str)->int:
    """Turn the presentation of the string to integer

    Parameters
    ----------
    a:int
        A covector in int form

    Returns
    -------
    int:
        Return the integer that is the combination of the plus and the min string
    """
    if len(a)>1:
        b=a[:1] # the first string
        c=a[1:]
        d=0 if b=="0" else 1 if b=="+" else 2
        return(d+3*covector_get_int(c))
    else:
        d=0 if a=="0" else 1 if a=="+" else 2
        return(d)

def covector_combine_int(a:int,b:int,lengte:int)->int:
    """Combine two covectors into a new one

    Parameters
    ----------
    a:int
        A covector in int form
    b:int
        A covector in int form
    lengte:int
        The length of the covector, i.e. dimension of the OM

    Returns
    -------
    int:
        Return the integer that is the combination of the plus and the min string
    """
    ia=a%3
    ib=b%3
    if ia==0:
        ic=ib
    else:
        ic=ia
    if lengte>1:
        return(ic+3*combine_covector_int(a//3,b//3,lengte-1))
    else:
        return(ic)

def covector_str_support_str(a:int)->str:
    """
    Return a bitset which is the support
    String of zeroes and ones
    Input should be a valid covector

    Parameters
    ----------
    a:str
        A string that should be validated

    Returns
    -------
    str:
        A binary support string

    """

def covector_str_support_str(a:str)->str:
    """
    Return a bitset which is the support
    String of zeroes and ones
    Input should be a valid covector

    Parameters
    ----------
    a:str
        A string that should be validated

    Returns
    -------
    str:
        A binary support string

    """
    if not(covector_validate_str(a)):
        raise RuntimeError("covector_str_support_str: The input should be a covector str")
    e=1
    s=0
    for x,y in zip(a,range(0,len(a))):
        f=0 if x=="0" else 1
        s=s+f*e
        e=e*2
    return(s)

def covector_int_support_str(a:int,lengte:int)->str:
    """Given the covector as an integer return the support as a string with zeros and ones

    Parameters
    ----------

    a:int
        A covector in int form
    lengte:int
        The length of the covector, i.e. dimension of the OM

    Returns
    -------
    
    """
    a=i%3
    if lengte>1:
        c=covector_int_support_str(i//3,lengte-1)
        if a==0:
            return("0"+c)
        else:
            return("1"+c)
    else:
        if a==0:
            return("0")
        elif a==1:
            return("+")
        else:
            return("-")


def covector_str_support_np(a:str)->str:
    """Return a bitset which is the support in string form

    Notes
    -----

    String of zeroes and ones

    Parameters
    ----------

    a:str
        A covector in str form

    Returns
    -------

    str:
        A covector in str form
    """
    e=1
    s=0
    for x,y in zip(a,range(0,len(a))):
        f=0 if x=="0" else 1
        s=s+f*e
        e=e*2
    return(s)

def covector_scd_str(a:str,b:str)->str:
    """Return the support where the two have opposite signs

    Parameters
    ----------

    a:str
        A covector in str form
    b:str
        A covector in str form

    Returns
    -------

    str:
        Return the string that is the combination of the plus and the min string
    """
    if len(a)<len(b) or len(b)<len(a):
        raise RuntimeError("covector_combine_str covectors have different length")



def covector_combine_str(a:str,b:str)->str:
    """combine two string covectors

    Parameters
    ----------

    a:str
        A covector in str form
    b:str
        A covector in str form

    Returns
    -------

    str:
        Return the string that is the combination of the plus and the min string

    """
    if len(a)<len(b) or len(b)<len(a):
        raise RuntimeError("covector_combine_str covectors have different length")
    def comb_(a,b):
        return(b if a==" " else a)
    return("".join([comb_(x,y) for x,y in zip(a,b)]))

def covector_negative_str(a:str)->str:
    """Get the negative of the covector in string form

    Parameters
    ----------
    a:str
        A covector in str form

    Returns
    -------
    str:
        Return the string that is the combination of the plus and the min string
    """
    return("".join([("+" if x=="-" else "-" if x=="+" else "0") for x in a]))


def covector_str_orthogonal(a:str,b:str)->bool:
    """Checks if two covectors are orthogonal
    Notes
    -----

    Either the supports are disjoint, or there are e,f in the intersection of supports such that a(e)b(e)=-a(f)b(f).
    So for instance 

    Parameters
    ----------

    a:str
        A covector in str form
    b:str
        A covector in str form

    Returns
    -------
    bool:
        If True then they are orthogonal

    """
    if len(a)!=len(b):
        raise RunTimeError("covector_str_orthogonal: vectors of unequal length")
    disjointsupport=[(x=="0")&(y!="0")|(y=="0")&(x!="0") for x,y in zip(a,b)]
    if all(disjointsupport):
        pass
    pass

def covector_negative_int(a:int,lengte:int)->int:
    """Get the negative of the covector in integer form

    Parameters
    ----------
    a:int
        A covector in int form
    lengte:int
        The dimension of the Oriented Matroid

    Returns
    -------
    int:
        Return the integer that is the combination of the plus and the min integer 
    """
    c=a%3
    if lengte>1:
        return((0 if c==0 else 1 if c==2 else 2)+3*covector_negative_int(a/3,lengte-1))
    else:
        return(0 if c==0 else 1 if c==2 else 2)

def intermediate_covector(a:int,b:int,lengte:int,j:int)->int:
    """

    Parameters
    ----------

    a:int
        The first integer
    Return the one with
    Check that j is in the separation set otherwise return a SeparationSetError
    Find the covector that is zero on j
    Where j is in the a(j)*b(j)=-. I.e. they both have a different sign

    """
    
    # first check that j is 
    if ((j>lengte) | (j<1)):
        raise RunTimeError("intermediate_covector : j should be between 1 and n")
    # if j=1 then we just need to check whether the mod 3 number is OK
    # if j=2 then we need to divide by 3
    ja=(a//(3**(j-1)))%3
    jb=(b//(3**(j-1)))%3
    if ja*jb!=2:
        raise RunTimeError("intermediate_covector : j is not opposite sign ")
    
    return(0)

def check_if_OM(a:List[int],lengte:int)->bool:
    """
    Check that the set is a cocircuit set, by checking that all the axioms hold
    I.e. that 
    """
    pass
