#include "kappalib.h"

//stathera gia to plithos twn fibonacci pou tha upologistoun
const int MAXN = 15;

//sunartisi pou upologizei ton n-osto arithmo fibonacci 
int fibonacci ( int n ) 
{ 
    int a , b , tmp , i;

    //arxikopoiisi metablitwn 
    a = 0;
    b = 1;
    i = 2;

    //upologismos fibonacci me while 
    while ( i <= n ) 
    { 
        tmp = a + b;
        a = b;
        b = tmp;
        i = i + 1;
    }

    //epistrofi apotelesmatos
    return b ;
} 

int main(int argc, char *argv[]) 
{ 
    int i;

    writeText ( "Akolouthia Fibonacci:\n" );

    //tupwnei ola ta fibonacci mexri MAXN 
    for ( int i = 1 ; i <= 15 ; ++i ) 
    { 
        writeText ( "fib(" );
        writeInt ( i );
        writeText ( ") = " );
        writeInt ( fibonacci ( i ) );
        writeText ( "\n" );
    }
} 
