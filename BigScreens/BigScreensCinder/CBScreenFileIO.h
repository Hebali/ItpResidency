/*    BigScreens for Cinder    */
/* ITP Residency Code Projects */
/*  Patrick Hebron, 2011-2012  */
/*    patrick.hebron@nyu.edu   */

#ifndef _CBSCREEN_FILEIO_
#define _CBSCREEN_FILEIO_

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <vector>

class CBScreenFileIO {
public:
    CBScreenFileIO() {}
    
    static bool readFile(string FileName, vector<string>* FileOutput) {    
        string      currLine;
        ifstream    theFile(FileName.c_str());
        
        if(theFile.is_open()) {
            while(theFile.good()) {
                getline(theFile,currLine);
                FileOutput->push_back(currLine);
            }
            theFile.close();
            return true;
        }
        return false;
    }
    
    static void tokenizeString(string Str, char Delim, vector<string>* Tokens) {
        stringstream ss(Str);
        string currT;
        while(getline(ss,currT,Delim)) {
            if(!currT.empty())
                Tokens->push_back(currT);
        }
    }
};


#endif
