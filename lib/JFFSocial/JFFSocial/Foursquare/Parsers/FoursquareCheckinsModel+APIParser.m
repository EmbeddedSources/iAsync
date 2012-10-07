#import "FoursquareCheckinsModel+APIParser.h"

@implementation FoursquareCheckinsModel (APIParser)

+ (id)fqCheckinModelWithDict:(NSDictionary *)jsonObject error:(NSError **)outError
{
    id jsonPattern = @{
    @"id"   : [NSString class],
    @"type" : [NSString class],
    };
    
    if( ![JFFJsonObjectValidator validateJsonObject:jsonObject
                                    withJsonPattern:jsonPattern
                                              error:outError]) {
        return nil;
    }
    
    FoursquareCheckinsModel *checkin = [self new];
    
    checkin.checkinID = jsonObject[@"id"];
    checkin.type      = jsonObject[@"type"];
    
    return checkin;
}

@end

/*

 {
 id: "5051a006e4b08eccb1257587"
 createdAt: 1347526662
 type: "checkin"
 timeZoneOffset: 180
 venue: {
 id: "4bc885700050b713b97eba3b"
 name: "Мост-Сити центр / Most-City Center"
 contact: { }
 location: {
 address: "вул. Глінки, 2"
 crossStreet: "вул. Харківська"
 lat: 48.46651922379868
 lng: 35.05054950714111
 city: "Дніпропетровськ"
 state: "Дніпропетровська обл."
 country: "Ukraine"
 cc: "UA"
 }
 categories: [
 {
 id: "4bf58dd8d48988d1fd941735"
 name: "Mall"
 pluralName: "Malls"
 shortName: "Mall"
 icon: {
 prefix: "https://foursquare.com/img/categories_v2/shops/mall_"
 suffix: ".png"
 }
 primary: true
 }
 ]
 verified: false
 stats: {
 checkinsCount: 10749
 usersCount: 1748
 tipCount: 24
 }
 likes: {
 count: 17
 groups: [
 {
 type: "others"
 count: 17
 items: [ ]
 }
 ]
 summary: "17 likes"
 }
 like: false
 friendVisits: {
 count: 0
 summary: "You've been here"
 items: [
 {
 visitedCount: 1
 liked: false
 user: {
 id: "36005164"
 firstName: "Petia"
 lastName: "Petrov"
 relationship: "self"
 photo: {
 prefix: "https://irs2.4sqi.net/img/user/"
 suffix: "/4ZQUQZHNRWPWGVI4.jpg"
 }
 }
 }
 ]
 }
 beenHere: {
 count: 1
 marked: false
 }
 }
 likes: {
 count: 0
 groups: [ ]
 }
 like: false
 photos: {
 count: 0
 items: [ ]
 }
 comments: {
 count: 0
 items: [ ]
 }
 source: {
 name: "foursquare for iPhone"
 url: "https://foursquare.com/download/#/iphone"
 }
 }
*/