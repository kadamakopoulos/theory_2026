#include "kappalib.h"

/* kaθolikes metavlites */
int a , b , result;

/* synartisi ypologismou tetragwnou */
int square ( int n ) 
{ 
    int i;
    i = n * n;
    return i ;
} 

/* synartisi gia na typtei grammi */
void printLine ( ) 
{ 
    writeText ( "----------\n" );
} 

int main(int argc, char *argv[]) 
{ 
    int i;

    /* typtw titlo */
    writeText ( "Tetragwna:\n" );

    /* epilogi apo 1 ews 8 */
    for ( int i = 1 ; i <= 8 ; ++i ) 
    { 
        writeInt ( i );
        writeText ( " * " );
        writeInt ( i );
        writeText ( " = " );
        writeInt ( square ( i ) );
        writeText ( "\n" );
    }

    printLine ( );

    /* diavazw 2 arithmous kai ypologizw athroisma */
    writeText ( "Dose 2 arithmous: " );
    a = readInt ( );
    b = readInt ( );
    result = a + b;
    writeText ( "Athroisma: " );
    writeInt ( result );
    writeText ( "\n" );
} 
