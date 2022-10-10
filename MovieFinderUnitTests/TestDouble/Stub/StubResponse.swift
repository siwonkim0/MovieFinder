//
//  StubResponse.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/10/09.
//

import Foundation

struct StubResponse {
    static let movieList: Data = """
{
    "page": 1,
    "results": [
        {
            "adult": false,
            "backdrop_path": "/qaTzVAW1u16WFNsepjCrilBuInc.jpg",
            "genre_ids": [
                16,
                28,
                10751,
                35,
                878
            ],
            "id": 539681,
            "original_language": "en",
            "original_title": "DC League of Super-Pets",
            "overview": "When Superman and the rest of the Justice League are kidnapped, Krypto the Super-Dog must convince a rag-tag shelter pack - Ace the hound, PB the potbellied pig, Merton the turtle and Chip the squirrel - to master their own newfound powers and help him rescue the superheroes.",
            "popularity": 1772.214,
            "poster_path": "/r7XifzvtezNt31ypvsmb6Oqxw49.jpg",
            "release_date": "2022-07-27",
            "title": "DC League of Super-Pets",
            "video": false,
            "vote_average": 7.5,
            "vote_count": 755
        }
    ],
    "total_pages": 150,
    "total_results": 2997
}

""".data(using: .utf8)!
}
