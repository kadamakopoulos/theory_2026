#include "kappalib.h"

/* stathera gia to plithos twn fibonacci pou tha ypologistoun */
const int MAXN = 15;

/* synartisi pou ypologizei ton n-osto arithmo fibonacci */
int fibonacci ( int n ) 
{ 
    int a , b , tmp , i;

    /* arxikopoiisi metavlitwn */
    a = 0;
    b = 1;
    i = 2;

    /* ypologismos fibonacci me while */
    while ( i <= n ) 
    { 
        tmp = a + b;
        a = b;
        b = tmp;
        i = i + 1;
    }

    /* epistrofi apotelesmatos */
    return b ;
} 

int main(int argc, char *argv[]) 
{ 
    int i;

    writeText ( "Akolouthia Fibonacci:\n" );

    /* typtw ola ta fibonacci mexri MAXN */
    for ( int i = 1 ; i <= 15 ; ++i ) 
    { 
        writeText ( "fib(" );
        writeInt ( i );
        writeText ( ") = " );
        writeInt ( fibonacci ( i ) );
        writeText ( "\n" );
    }
} 
