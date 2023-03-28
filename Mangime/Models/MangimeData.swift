//
//  MangimeData.swift
//  Mangime
//
//  Created by Mesiow on 3/17/23.
//

import Foundation

struct MangimeData : Codable{
    let pagination : Pagination;
    let data : [DataObject];
}

struct DataObject : Codable {
    let images : Images;
    let trailer : Trailer?
    let title : String;
    let type : String;
    let synopsis : String?
    var aired : Aired?
    var published : Aired?
    let score : Float?
}

struct Pagination : Codable {
    let last_visible_page : Int;
}

struct Images : Codable {
    let jpg : JpgImgs
}

struct JpgImgs : Codable{
    let image_url : String;
    let small_image_url : String;
    let large_image_url : String;
}

struct Trailer : Codable {
    let youtube_id : String?;
}

struct Aired : Codable {
    let string : String;
}
