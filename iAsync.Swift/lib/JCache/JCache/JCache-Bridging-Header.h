//
//  JCache-Bridging-Header.h
//  JCache
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

#ifndef JCache_JCache_Bridging_Header_h
#define JCache_JCache_Bridging_Header_h

#define BRIDGING_SQLITE_OK           0   /* Successful result */
#define BRIDGING_SQLITE_ROW         100  /* sqlite3_step() has another row ready */
#define BRIDGING_SQLITE_DONE        101  /* sqlite3_step() has finished executing */

typedef struct sqlite3_stmt sqlite3_stmt;
typedef struct sqlite3 sqlite3;

extern int bridging_sqlite3_step(sqlite3_stmt*);
extern const unsigned char *bridging_sqlite3_column_text(sqlite3_stmt*, int iCol);
extern double bridging_sqlite3_column_double(sqlite3_stmt*, int iCol);
extern int bridging_sqlite3_finalize(sqlite3_stmt *pStmt);
extern int bridging_sqlite3_open(
                        const char *filename,   /* Database filename (UTF-8) */
                        sqlite3 **ppDb          /* OUT: SQLite db handle */
);
extern int bridging_sqlite3_close(sqlite3 *);
extern int bridging_sqlite3_exec(
                        sqlite3*,                                  /* An open database */
                        const char *sql,                           /* SQL to be evaluated */
                        int (*callback)(void*,int,char**,char**),  /* Callback function */
                        void *,                                    /* 1st argument to callback */
                        char **errmsg                              /* Error msg written here */
);
extern int bridging_sqlite3_prepare_v2(
                              sqlite3 *db,            /* Database handle */
                              const char *zSql,       /* SQL statement, UTF-8 encoded */
                              int nByte,              /* Maximum length of zSql in bytes. */
                              sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
                              const char **pzTail     /* OUT: Pointer to unused portion of zSql */
);
extern void bridging_sqlite3_free(void*);
extern const char *bridging_sqlite3_errmsg(sqlite3*);

#endif
