#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class CXMLDocument;

CXMLDocument* xmlDocumentWithData( NSData* data_, NSError** outError_ );

JFFAsyncOperationBinder xmlDocumentWithDataAsyncBinder( void );
JFFAsyncOperationBinder xmlDocumentWithStringAsyncBinder( void );
