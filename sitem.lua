--[[{
  "name": "Rezeroturkce",
  "baseUrl": "https://www.rezeroturkce.com/",
  "lang": "tr",
  "version": "1.0.0",
  "libVer": "1"
}]]--

-- Sitenin Cloudflare korumasını gerçek mobil tarayıcı gibi aşan fonksiyon
function getPageWithBypass(url)
    local headers = {
        ["User-Agent"] = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36",
        ["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
        ["Accept-Language"] = "tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7",
        ["Referer"] = "https://www.rezeroturkce.com/"
    }
    return http.get(url, headers)
end

function parsePopularListing(page, query)
    local novels = {}
    -- Shosetsu/Bunori içinde elle arama yapabilmen için sitenin ana adresi
    table.insert(novels, {
        title = "Re:Zero Türkçe",
        url = "https://www.rezeroturkce.com/",
        imageUrl = ""
    })
    return novels
end

function parseNovelDetails(novelUrl)
    local novel = {}
    local response = getPageWithBypass(novelUrl)
    local soup = bsu.parse(response)
    
    novel.title = "Re:Zero Türkçe Roman"
    novel.chapters = {}
    
    -- Sitedeki tüm bölüm sekmelerini ve linklerini nokta atışı toplar
    for _, a in ipairs(soup:findAll("a")) do
        local href = a:attr("href")
        local text = a:text():trim()
        if href and (href:find("/p/") or href:find("bolum") or href:find("chapter")) and text ~= "" then
            table.insert(novel.chapters, {
                title = text,
                url = url.absolute("https://www.rezeroturkce.com/", href)
            })
        end
    end
    return novel
end

function parseChapterDetails(chapterUrl)
    local chapter = {}
    local response = getPageWithBypass(chapterUrl)
    local soup = bsu.parse(response)
    
    local paragraphs = {}
    
    -- Rezeroturkce sitesindeki asıl yazıların tutulduğu post-body alanını hedef alır
    local contentArea = soup:find(nil, {class="post-body"}) or soup:find(nil, {id="post-body"}) or soup:find("article")
    
    if contentArea then
        for _, p in ipairs(contentArea:findAll("p")) do
            local pText = p:text():trim()
            if pText ~= "" then
                table.insert(paragraphs, pText)
            end
        end
    else
        -- Eğer özel alan bulunamazsa sayfadaki tüm p etiketlerini tarar
        for _, p in ipairs(soup:findAll("p")) do
            local pText = p:text():trim()
            if pText ~= "" then
                table.insert(paragraphs, pText)
            end
        end
    end
    
    chapter.content = table.concat(paragraphs, "\n\n")
    return chapter
end
