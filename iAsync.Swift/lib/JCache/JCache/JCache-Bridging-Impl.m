//
//  JCache-Bridging-Header.m
//  JCache
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <sqlite3.h>

int bridging_sqlite3_step(sqlite3_stmt* arg) {
    
    return sqlite3_step(arg);
}

const unsigned char *bridging_sqlite3_column_text(sqlite3_stmt* stmt, int iCol) {
    
    return sqlite3_column_text(stmt, iCol);
}

double bridging_sqlite3_column_double(sqlite3_stmt* stmt, int iCol) {
    
    return sqlite3_column_double(stmt, iCol);
}

int bridging_sqlite3_finalize(sqlite3_stmt *pStmt) {
    
    return sqlite3_finalize(pStmt);
}

int bridging_sqlite3_open(
                 const char *filename,   /* Database filename (UTF-8) */
                 sqlite3 **ppDb          /* OUT: SQLite db handle */
) {
    
    return sqlite3_open(filename, ppDb);
}

int bridging_sqlite3_close(sqlite3 *stm) {
    
    return sqlite3_close(stm);
}

int bridging_sqlite3_exec(
                 sqlite3* db,                                  /* An open database */
                 const char *sql,                           /* SQL to be evaluated */
                 int (*callback)(void*,int,char**,char**),  /* Callback function */
                 void *ptr,                                    /* 1st argument to callback */
                 char **errmsg                              /* Error msg written here */
) {
    
    return sqlite3_exec(db, sql, callback, ptr, errmsg);
}

int bridging_sqlite3_prepare_v2(
                                sqlite3 *db,            /* Database handle */
                                const char *zSql,       /* SQL statement, UTF-8 encoded */
                                int nByte,              /* Maximum length of zSql in bytes. */
                                sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
                                const char **pzTail     /* OUT: Pointer to unused portion of zSql */
) {
    
    return sqlite3_prepare_v2(db, zSql, nByte, ppStmt, pzTail);
}

void bridging_sqlite3_free(void* db) {
    
    return sqlite3_free(db);
}

const char *bridging_sqlite3_errmsg(sqlite3* sql) {
    
    return sqlite3_errmsg(sql);
}
