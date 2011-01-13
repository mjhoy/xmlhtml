{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE OverloadedStrings         #-}
{-# LANGUAGE ScopedTypeVariables       #-}

module Text.XmlHtml.Tests (tests) where

import           Blaze.ByteString.Builder
import           Control.Exception as E
import           Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as B
import           Data.Text ()                  -- for string instance
import qualified Data.Text.Encoding as T
import           System.IO.Unsafe
import           Test.Framework
import           Test.Framework.Providers.HUnit
import           Test.HUnit hiding (Test)
import           Text.Blaze.Renderer.XmlHtml() -- Just to get it in hpc
import           Text.XmlHtml
import           Text.XmlHtml.Cursor()         -- Just to get it in hpc
import           Text.XmlHtml.OASISTest

tests :: [Test]
tests = [
    -- XML parsing tests
    testIt "emptyDocument          " emptyDocument,
    testIt "publicDocType          " publicDocType,
    testIt "systemDocType          " systemDocType,
    testIt "emptyDocType           " emptyDocType,
    testIt "textOnly               " textOnly,
    testIt "textWithRefs           " textWithRefs,
    testIt "untermRef              " untermRef,
    testIt "textWithCDATA          " textWithCDATA,
    testIt "cdataOnly              " cdataOnly,
    testIt "commentOnly            " commentOnly,
    testIt "emptyElement           " emptyElement,
    testIt "emptyElement2          " emptyElement2,
    testIt "elemWithText           " elemWithText,
    testIt "xmlDecl                " xmlDecl,
    testIt "procInst               " procInst,
    testIt "badDoctype1            " badDoctype1,
    testIt "badDoctype2            " badDoctype2,
    testIt "badDoctype3            " badDoctype3,
    testIt "badDoctype4            " badDoctype4,
    testIt "badDoctype5            " badDoctype5,

    -- Repeat XML tests with HTML parser
    testIt "emptyDocumentHTML      " emptyDocumentHTML,
    testIt "publicDocTypeHTML      " publicDocTypeHTML,
    testIt "systemDocTypeHTML      " systemDocTypeHTML,
    testIt "emptyDocTypeHTML       " emptyDocTypeHTML,
    testIt "textOnlyHTML           " textOnlyHTML,
    testIt "textWithRefsHTML       " textWithRefsHTML,
    testIt "textWithCDataHTML      " textWithCDataHTML,
    testIt "cdataOnlyHTML          " cdataOnlyHTML,
    testIt "commentOnlyHTML        " commentOnlyHTML,
    testIt "emptyElementHTML       " emptyElementHTML,
    testIt "emptyElement2HTML      " emptyElement2HTML,
    testIt "elemWithTextHTML       " elemWithTextHTML,
    testIt "xmlDeclHTML            " xmlDeclHTML,
    testIt "procInstHTML           " procInstHTML,
    testIt "badDoctype1HTML        " badDoctype1HTML,
    testIt "badDoctype2HTML        " badDoctype2HTML,
    testIt "badDoctype3HTML        " badDoctype3HTML,
    testIt "badDoctype4HTML        " badDoctype4HTML,
    testIt "badDoctype5HTML        " badDoctype5HTML,

    -- HTML parser quirks
    testIt "voidElem               " voidElem,
    testIt "caseInsDoctype1        " caseInsDoctype1,
    testIt "caseInsDoctype2        " caseInsDoctype2,
    testIt "voidEmptyElem          " voidEmptyElem,
    testIt "rawTextElem            " rawTextElem,
    testIt "rcdataElem             " rcdataElem,
    testIt "endTagCase             " endTagCase,
    testIt "hexEntityCap           " hexEntityCap,
    testIt "laxAttrName            " laxAttrName,
    testIt "emptyAttr              " emptyAttr,
    testIt "unquotedAttr           " unquotedAttr,
    testIt "laxAttrVal             " laxAttrVal,
    testIt "ampersandInText        " ampersandInText,
    testIt "omitOptionalEnds       " omitOptionalEnds,
    testIt "omitEndHEAD            " omitEndHEAD,
    testIt "omitEndLI              " omitEndLI,
    testIt "omitEndDT              " omitEndDT,
    testIt "omitEndDD              " omitEndDD,
    testIt "omitEndP               " omitEndP,
    testIt "omitEndRT              " omitEndRT,
    testIt "omitEndRP              " omitEndRP,
    testIt "omitEndOPTGRP          " omitEndOPTGRP,
    testIt "omitEndOPTION          " omitEndOPTION,
    testIt "omitEndCOLGRP          " omitEndCOLGRP,
    testIt "omitEndTHEAD           " omitEndTHEAD,
    testIt "omitEndTBODY           " omitEndTBODY,
    testIt "omitEndTFOOT           " omitEndTFOOT,
    testIt "omitEndTR              " omitEndTR,
    testIt "omitEndTD              " omitEndTD,
    testIt "omitEndTH              " omitEndTH,
    testIt "testNewRefs            " testNewRefs,

    -- XML Rendering Tests
    testIt "renderByteOrderMark    " renderByteOrderMark,
    testIt "singleQuoteInSysID     " singleQuoteInSysID,
    testIt "doubleQuoteInSysID     " doubleQuoteInSysID,
    testIt "bothQuotesInSysID      " bothQuotesInSysID,
    testIt "doubleQuoteInPubID     " doubleQuoteInPubID,
    testIt "doubleDashInComment    " doubleDashInComment,
    testIt "trailingDashInComment  " trailingDashInComment,
    testIt "renderEmptyText        " renderEmptyText,
    testIt "singleQuoteInAttr      " singleQuoteInAttr,
    testIt "doubleQuoteInAttr      " doubleQuoteInAttr,
    testIt "bothQuotesInAttr       " bothQuotesInAttr,

    -- HTML Repeated Rendering Tests
    testIt "hRenderByteOrderMark   " hRenderByteOrderMark,
    testIt "hSingleQuoteInSysID    " hSingleQuoteInSysID,
    testIt "hDoubleQuoteInSysID    " hDoubleQuoteInSysID,
    testIt "hBothQuotesInSysID     " hBothQuotesInSysID,
    testIt "hDoubleQuoteInPubID    " hDoubleQuoteInPubID,
    testIt "hDoubleDashInComment   " hDoubleDashInComment,
    testIt "hTrailingDashInComment " hTrailingDashInComment,
    testIt "hRenderEmptyText       " hRenderEmptyText,
    testIt "hSingleQuoteInAttr     " hSingleQuoteInAttr,
    testIt "hDoubleQuoteInAttr     " hDoubleQuoteInAttr,
    testIt "hBothQuotesInAttr      " hBothQuotesInAttr,

    -- HTML Rendering Quirks
    testIt "renderHTMLVoid         " renderHTMLVoid,
    testIt "renderHTMLVoid2        " renderHTMLVoid2,
    testIt "renderHTMLRaw          " renderHTMLRaw,
    testIt "renderHTMLRawMult      " renderHTMLRawMult,
    testIt "renderHTMLRaw2         " renderHTMLRaw2,
    testIt "renderHTMLRaw3         " renderHTMLRaw3,
    testIt "renderHTMLRaw4         " renderHTMLRaw4,
    testIt "renderHTMLRcdata       " renderHTMLRcdata,
    testIt "renderHTMLRcdataMult   " renderHTMLRcdataMult,
    testIt "renderHTMLRcdata2      " renderHTMLRcdata2,
    testIt "renderHTMLAmpAttr1     " renderHTMLAmpAttr1,
    testIt "renderHTMLAmpAttr2     " renderHTMLAmpAttr2
    ]
    ++ testsOASIS

testIt :: TestName -> Bool -> Test
testIt name b = testCase name $ assertBool name b

------------------------------------------------------------------------------
-- Code adapted from ChasingBottoms.
--
-- Adding an actual dependency isn't possible because Cabal refuses to build
-- the package due to version conflicts.
--
-- isBottom is impossible to write, but very useful!  So we defy the
-- impossible, and write it anyway.
------------------------------------------------------------------------------

isBottom :: a -> Bool
isBottom a = unsafePerformIO $
    (E.evaluate a >> return False)
    `E.catch` \ (_ :: ErrorCall)        -> return True
    `E.catch` \ (_ :: PatternMatchFail) -> return True

------------------------------------------------------------------------------

isLeft :: Either a b -> Bool
isLeft = either (const True) (const False)

e :: Encoding
e = UTF8

------------------------------------------------------------------------------
-- XML Parsing Tests ---------------------------------------------------------
------------------------------------------------------------------------------

emptyDocument :: Bool
emptyDocument = parseXML "" ""
    == Right (XmlDocument e Nothing [])

publicDocType :: Bool
publicDocType = parseXML "" "<!DOCTYPE tag PUBLIC \"foo\" \"bar\">"
    == Right (XmlDocument e (Just (DocType "tag" (Public "foo" "bar") NoInternalSubset)) [])

systemDocType :: Bool
systemDocType = parseXML "" "<!DOCTYPE tag SYSTEM \"foo\">"
    == Right (XmlDocument e (Just (DocType "tag" (System "foo") NoInternalSubset)) [])

emptyDocType :: Bool
emptyDocType  = parseXML "" "<!DOCTYPE tag >"
    == Right (XmlDocument e (Just (DocType "tag" NoExternalID NoInternalSubset)) [])

textOnly :: Bool
textOnly      = parseXML "" "sldhfsklj''a's s"
    == Right (XmlDocument e Nothing [TextNode "sldhfsklj''a's s"])

textWithRefs :: Bool
textWithRefs  = parseXML "" "This is Bob&apos;s sled"
    == Right (XmlDocument e Nothing [TextNode "This is Bob's sled"])

untermRef :: Bool
untermRef     = isLeft (parseXML "" "&#X6a")

textWithCDATA :: Bool
textWithCDATA = parseXML "" "Testing <![CDATA[with <some> c]data]]>"
    == Right (XmlDocument e Nothing [TextNode "Testing with <some> c]data"])

cdataOnly :: Bool
cdataOnly     = parseXML "" "<![CDATA[ Testing <![CDATA[ test ]]>"
    == Right (XmlDocument e Nothing [TextNode " Testing <![CDATA[ test "])

commentOnly :: Bool
commentOnly   = parseXML "" "<!-- this <is> a \"comment -->"
    == Right (XmlDocument e Nothing [Comment " this <is> a \"comment "])

emptyElement :: Bool
emptyElement  = parseXML "" "<myElement/>"
    == Right (XmlDocument e Nothing [Element "myElement" [] []])

emptyElement2 :: Bool
emptyElement2  = parseXML "" "<myElement />"
    == Right (XmlDocument e Nothing [Element "myElement" [] []])

elemWithText :: Bool
elemWithText  = parseXML "" "<myElement>text</myElement>"
    == Right (XmlDocument e Nothing [Element "myElement" [] [TextNode "text"]])

xmlDecl :: Bool
xmlDecl       = parseXML "" "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
    == Right (XmlDocument e Nothing [])

procInst :: Bool
procInst      = parseXML "" "<?myPI This''is <not> parsed!?>"
    == Right (XmlDocument e Nothing [])

badDoctype1 :: Bool
badDoctype1    = isLeft $ parseXML "" "<!DOCTYPE>"

badDoctype2 :: Bool
badDoctype2    = isLeft $ parseXML "" "<!DOCTYPE html BAD>"

badDoctype3 :: Bool
badDoctype3    = isLeft $ parseXML "" "<!DOCTYPE html SYSTEM>"

badDoctype4 :: Bool
badDoctype4    = isLeft $ parseXML "" "<!DOCTYPE html PUBLIC \"foo\">"

badDoctype5 :: Bool
badDoctype5    = isLeft $ parseXML "" ("<!DOCTYPE html SYSTEM \"foo\" "
                                       `B.append` "PUBLIC \"bar\" \"baz\">")

------------------------------------------------------------------------------
-- HTML Repetitions of XML Parsing Tests -------------------------------------
------------------------------------------------------------------------------

emptyDocumentHTML :: Bool
emptyDocumentHTML = parseHTML "" ""
    == Right (HtmlDocument e Nothing [])

publicDocTypeHTML :: Bool
publicDocTypeHTML = parseHTML "" "<!DOCTYPE tag PUBLIC \"foo\" \"bar\">"
    == Right (HtmlDocument e (Just (DocType "tag" (Public "foo" "bar") NoInternalSubset)) [])

systemDocTypeHTML :: Bool
systemDocTypeHTML = parseHTML "" "<!DOCTYPE tag SYSTEM \"foo\">"
    == Right (HtmlDocument e (Just (DocType "tag" (System "foo") NoInternalSubset)) [])

emptyDocTypeHTML :: Bool
emptyDocTypeHTML  = parseHTML "" "<!DOCTYPE tag >"
    == Right (HtmlDocument e (Just (DocType "tag" NoExternalID NoInternalSubset)) [])

textOnlyHTML :: Bool
textOnlyHTML      = parseHTML "" "sldhfsklj''a's s"
    == Right (HtmlDocument e Nothing [TextNode "sldhfsklj''a's s"])

textWithRefsHTML :: Bool
textWithRefsHTML  = parseHTML "" "This is Bob&apos;s sled"
    == Right (HtmlDocument e Nothing [TextNode "This is Bob's sled"])

textWithCDataHTML :: Bool
textWithCDataHTML = parseHTML "" "Testing <![CDATA[with <some> c]data]]>"
    == Right (HtmlDocument e Nothing [TextNode "Testing with <some> c]data"])

cdataOnlyHTML :: Bool
cdataOnlyHTML     = parseHTML "" "<![CDATA[ Testing <![CDATA[ test ]]>"
    == Right (HtmlDocument e Nothing [TextNode " Testing <![CDATA[ test "])

commentOnlyHTML :: Bool
commentOnlyHTML   = parseHTML "" "<!-- this <is> a \"comment -->"
    == Right (HtmlDocument e Nothing [Comment " this <is> a \"comment "])

emptyElementHTML :: Bool
emptyElementHTML  = parseHTML "" "<myElement/>"
    == Right (HtmlDocument e Nothing [Element "myElement" [] []])

emptyElement2HTML :: Bool
emptyElement2HTML = parseHTML "" "<myElement />"
    == Right (HtmlDocument e Nothing [Element "myElement" [] []])

elemWithTextHTML :: Bool
elemWithTextHTML  = parseHTML "" "<myElement>text</myElement>"
    == Right (HtmlDocument e Nothing [Element "myElement" [] [TextNode "text"]])

xmlDeclHTML :: Bool
xmlDeclHTML       = parseHTML "" "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
    == Right (HtmlDocument e Nothing [])

procInstHTML :: Bool
procInstHTML      = parseHTML "" "<?myPI This''is <not> parsed!?>"
    == Right (HtmlDocument e Nothing [])

badDoctype1HTML :: Bool
badDoctype1HTML    = isLeft $ parseHTML "" "<!DOCTYPE>"

badDoctype2HTML :: Bool
badDoctype2HTML    = isLeft $ parseHTML "" "<!DOCTYPE html BAD>"

badDoctype3HTML :: Bool
badDoctype3HTML    = isLeft $ parseHTML "" "<!DOCTYPE html SYSTEM>"

badDoctype4HTML :: Bool
badDoctype4HTML    = isLeft $ parseHTML "" "<!DOCTYPE html PUBLIC \"foo\">"

badDoctype5HTML :: Bool
badDoctype5HTML    = isLeft $ parseHTML "" ("<!DOCTYPE html SYSTEM \"foo\" "
                                       `B.append` "PUBLIC \"bar\" \"baz\">")

------------------------------------------------------------------------------
-- HTML Quirks Parsing Tests -------------------------------------------------
------------------------------------------------------------------------------

caseInsDoctype1 :: Bool
caseInsDoctype1 = parseHTML "" "<!dOcTyPe html SyStEm 'foo'>"
    == Right (HtmlDocument e (Just (DocType "html" (System "foo") NoInternalSubset)) [])

caseInsDoctype2 :: Bool
caseInsDoctype2 = parseHTML "" "<!dOcTyPe html PuBlIc 'foo' 'bar'>"
    == Right (HtmlDocument e (Just (DocType "html" (Public "foo" "bar") NoInternalSubset)) [])

voidElem :: Bool
voidElem      = parseHTML "" "<img>"
    == Right (HtmlDocument e Nothing [Element "img" [] []])

voidEmptyElem :: Bool
voidEmptyElem = parseHTML "" "<img/>"
    == Right (HtmlDocument e Nothing [Element "img" [] []])

rawTextElem :: Bool
rawTextElem   = parseHTML "" "<script>This<is'\"a]]>test&amp;</script>"
    == Right (HtmlDocument e Nothing [Element "script" [] [
                    TextNode "This<is'\"a]]>test&amp;"]
                    ])

rcdataElem :: Bool
rcdataElem    = parseHTML "" "<textarea>This<is>'\"a]]>test&amp;</textarea>"
    == Right (HtmlDocument e Nothing [Element "textarea" [] [
                    TextNode "This<is>'\"a]]>test&"]
                    ])

endTagCase :: Bool
endTagCase    = parseHTML "" "<testing></TeStInG>"
    == Right (HtmlDocument e Nothing [Element "testing" [] []])

hexEntityCap :: Bool
hexEntityCap  = parseHTML "" "&#X6a;"
    == Right (HtmlDocument e Nothing [TextNode "\x6a"])

laxAttrName :: Bool
laxAttrName   = parseHTML "" "<test val<fun=\"test\"></test>"
    == Right (HtmlDocument e Nothing [Element "test" [("val<fun", "test")] []])

emptyAttr :: Bool
emptyAttr     = parseHTML "" "<test attr></test>"
    == Right (HtmlDocument e Nothing [Element "test" [("attr", "")] []])

unquotedAttr :: Bool
unquotedAttr  = parseHTML "" "<test attr=you&amp;me></test>"
    == Right (HtmlDocument e Nothing [Element "test" [("attr", "you&me")] []])

laxAttrVal :: Bool
laxAttrVal    = parseHTML "" "<test attr=\"a &amp; d < b & c\"/>"
    == Right (HtmlDocument e Nothing [Element "test" [("attr", "a & d < b & c")] []])

ampersandInText :: Bool
ampersandInText   = parseHTML "" "&#X6a"
    == Right (HtmlDocument e Nothing [TextNode "&#X6a"])

omitOptionalEnds :: Bool
omitOptionalEnds   = parseHTML "" "<html><body><p></html>"
    == Right (HtmlDocument e Nothing [Element "html" [] [
                Element "body" [] [ Element "p" [] []]]])

omitEndHEAD :: Bool
omitEndHEAD   = parseHTML "" "<head><body>"
    == Right (HtmlDocument e Nothing [Element "head" [] [], Element "body" [] []])

omitEndLI :: Bool
omitEndLI     = parseHTML "" "<li><li>"
    == Right (HtmlDocument e Nothing [Element "li" [] [], Element "li" [] []])

omitEndDT :: Bool
omitEndDT     = parseHTML "" "<dt><dd>"
    == Right (HtmlDocument e Nothing [Element "dt" [] [], Element "dd" [] []])

omitEndDD :: Bool
omitEndDD     = parseHTML "" "<dd><dt>"
    == Right (HtmlDocument e Nothing [Element "dd" [] [], Element "dt" [] []])

omitEndP :: Bool
omitEndP      = parseHTML "" "<p><h1></h1>"
    == Right (HtmlDocument e Nothing [Element "p" [] [], Element "h1" [] []])

omitEndRT :: Bool
omitEndRT     = parseHTML "" "<rt><rp>"
    == Right (HtmlDocument e Nothing [Element "rt" [] [], Element "rp" [] []])

omitEndRP :: Bool
omitEndRP     = parseHTML "" "<rp><rt>"
    == Right (HtmlDocument e Nothing [Element "rp" [] [], Element "rt" [] []])

omitEndOPTGRP :: Bool
omitEndOPTGRP = parseHTML "" "<optgroup><optgroup>"
    == Right (HtmlDocument e Nothing [Element "optgroup" [] [], Element "optgroup" [] []])

omitEndOPTION :: Bool
omitEndOPTION = parseHTML "" "<option><option>"
    == Right (HtmlDocument e Nothing [Element "option" [] [], Element "option" [] []])

omitEndCOLGRP :: Bool
omitEndCOLGRP = parseHTML "" "<colgroup><tbody>"
    == Right (HtmlDocument e Nothing [Element "colgroup" [] [], Element "tbody" [] []])

omitEndTHEAD :: Bool
omitEndTHEAD  = parseHTML "" "<thead><tbody>"
    == Right (HtmlDocument e Nothing [Element "thead" [] [], Element "tbody" [] []])

omitEndTBODY :: Bool
omitEndTBODY  = parseHTML "" "<tbody><thead>"
    == Right (HtmlDocument e Nothing [Element "tbody" [] [], Element "thead" [] []])

omitEndTFOOT :: Bool
omitEndTFOOT  = parseHTML "" "<tfoot><tbody>"
    == Right (HtmlDocument e Nothing [Element "tfoot" [] [], Element "tbody" [] []])

omitEndTR :: Bool
omitEndTR     = parseHTML "" "<tr><tr>"
    == Right (HtmlDocument e Nothing [Element "tr" [] [], Element "tr" [] []])

omitEndTD :: Bool
omitEndTD     = parseHTML "" "<td><td>"
    == Right (HtmlDocument e Nothing [Element "td" [] [], Element "td" [] []])

omitEndTH :: Bool
omitEndTH     = parseHTML "" "<th><td>"
    == Right (HtmlDocument e Nothing [Element "th" [] [], Element "td" [] []])

testNewRefs :: Bool
testNewRefs   = parseHTML "" "&CenterDot;&doublebarwedge;&fjlig;"
    == Right (HtmlDocument e Nothing [TextNode "\x000B7\x02306\&fj"])

------------------------------------------------------------------------------
-- XML Rendering Tests -------------------------------------------------------
------------------------------------------------------------------------------

renderByteOrderMark :: Bool
renderByteOrderMark =
    toByteString (render (XmlDocument UTF16BE Nothing []))
    == T.encodeUtf16BE "\xFEFF<?xml version=\"1.0\" encoding=\"UTF-16\"?>\n"

-- (Appears at the beginning of all XML output)
utf8Decl :: ByteString
utf8Decl = T.encodeUtf8 "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"

singleQuoteInSysID :: Bool
singleQuoteInSysID =
    toByteString (render (XmlDocument UTF8
        (Just (DocType "html" (System "test\'ing") NoInternalSubset))
        []))
    == utf8Decl `B.append` "<!DOCTYPE html SYSTEM \"test\'ing\">"

doubleQuoteInSysID :: Bool
doubleQuoteInSysID =
    toByteString (render (XmlDocument UTF8
        (Just (DocType "html" (System "test\"ing") NoInternalSubset))
        []))
    == utf8Decl `B.append` "<!DOCTYPE html SYSTEM \'test\"ing\'>"

bothQuotesInSysID :: Bool
bothQuotesInSysID = isBottom $
    toByteString (render (XmlDocument UTF8
        (Just (DocType "html" (System "test\"\'ing") NoInternalSubset))
        []))

doubleQuoteInPubID :: Bool
doubleQuoteInPubID = isBottom $
    toByteString (render (XmlDocument UTF8
        (Just (DocType "html" (Public "test\"ing" "foo") NoInternalSubset))
        []))

doubleDashInComment :: Bool
doubleDashInComment = isBottom $
    toByteString (render (XmlDocument UTF8 Nothing [
        Comment "test--ing"
        ]))

trailingDashInComment :: Bool
trailingDashInComment = isBottom $
    toByteString (render (XmlDocument UTF8 Nothing [
        Comment "testing-"
        ]))

renderEmptyText :: Bool
renderEmptyText =
    toByteString (render (XmlDocument UTF8 Nothing [
        TextNode ""
        ]))
    == utf8Decl

singleQuoteInAttr :: Bool
singleQuoteInAttr =
    toByteString (render (XmlDocument UTF8 Nothing [
        Element "foo" [("bar", "test\'ing")] []
        ]))
    == utf8Decl `B.append` "<foo bar=\"test\'ing\"/>"

doubleQuoteInAttr :: Bool
doubleQuoteInAttr =
    toByteString (render (XmlDocument UTF8 Nothing [
        Element "foo" [("bar", "test\"ing")] []
        ]))
    == utf8Decl `B.append` "<foo bar=\'test\"ing\'/>"

bothQuotesInAttr :: Bool
bothQuotesInAttr =
    toByteString (render (XmlDocument UTF8 Nothing [
        Element "foo" [("bar", "test\'\"ing")] []
        ]))
    == utf8Decl `B.append` "<foo bar=\"test\'&quot;ing\"/>"

------------------------------------------------------------------------------
-- HTML Repeats of XML Rendering Tests ---------------------------------------
------------------------------------------------------------------------------

hRenderByteOrderMark :: Bool
hRenderByteOrderMark =
    toByteString (render (HtmlDocument UTF16BE Nothing []))
    == "\xFE\xFF"

hSingleQuoteInSysID :: Bool
hSingleQuoteInSysID =
    toByteString (render (HtmlDocument UTF8
        (Just (DocType "html" (System "test\'ing") NoInternalSubset))
        []))
    == "<!DOCTYPE html SYSTEM \"test\'ing\">"

hDoubleQuoteInSysID :: Bool
hDoubleQuoteInSysID =
    toByteString (render (HtmlDocument UTF8
        (Just (DocType "html" (System "test\"ing") NoInternalSubset))
        []))
    == "<!DOCTYPE html SYSTEM \'test\"ing\'>"

hBothQuotesInSysID :: Bool
hBothQuotesInSysID = isBottom $
    toByteString (render (HtmlDocument UTF8
        (Just (DocType "html" (System "test\"\'ing") NoInternalSubset))
        []))

hDoubleQuoteInPubID :: Bool
hDoubleQuoteInPubID = isBottom $
    toByteString (render (HtmlDocument UTF8
        (Just (DocType "html" (Public "test\"ing" "foo") NoInternalSubset))
        []))

hDoubleDashInComment :: Bool
hDoubleDashInComment = isBottom $
    toByteString (render (HtmlDocument UTF8 Nothing [
        Comment "test--ing"
        ]))

hTrailingDashInComment :: Bool
hTrailingDashInComment = isBottom $
    toByteString (render (HtmlDocument UTF8 Nothing [
        Comment "testing-"
        ]))

hRenderEmptyText :: Bool
hRenderEmptyText =
    toByteString (render (HtmlDocument UTF8 Nothing [
        TextNode ""
        ]))
    == ""

hSingleQuoteInAttr :: Bool
hSingleQuoteInAttr =
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "foo" [("bar", "test\'ing")] []
        ]))
    == "<foo bar=\"test\'ing\"></foo>"

hDoubleQuoteInAttr :: Bool
hDoubleQuoteInAttr =
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "foo" [("bar", "test\"ing")] []
        ]))
    == "<foo bar=\'test\"ing\'></foo>"

hBothQuotesInAttr :: Bool
hBothQuotesInAttr =
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "foo" [("bar", "test\'\"ing")] []
        ]))
    == "<foo bar=\"test\'&quot;ing\"></foo>"

------------------------------------------------------------------------------
-- HTML Quirks Rendering Tests -----------------------------------------------
------------------------------------------------------------------------------

renderHTMLVoid :: Bool
renderHTMLVoid =
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "img" [("src", "foo")] []
        ]))
    == "<img src=\'foo\' />"

renderHTMLVoid2 :: Bool
renderHTMLVoid2 = isBottom $
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "img" [] [TextNode "foo"]
        ]))

renderHTMLRaw :: Bool
renderHTMLRaw =
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "script" [("type", "text/javascript")] [
            TextNode "<testing>/&+</foo>"
            ]
        ]))
    == "<script type=\'text/javascript\'><testing>/&+</foo></script>"

renderHTMLRawMult :: Bool
renderHTMLRawMult =
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "script" [("type", "text/javascript")] [
            TextNode "foo",
            TextNode "bar"
            ]
        ]))
    == "<script type=\'text/javascript\'>foobar</script>"

renderHTMLRaw2 :: Bool
renderHTMLRaw2 = isBottom $
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "script" [("type", "text/javascript")] [
            TextNode "</script>"
            ]
        ]))

renderHTMLRaw3 :: Bool
renderHTMLRaw3 = isBottom $
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "script" [("type", "text/javascript")] [
            Comment "foo"
            ]
        ]))

renderHTMLRaw4 :: Bool
renderHTMLRaw4 = isBottom $
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "script" [("type", "text/javascript")] [
            TextNode "</scri",
            TextNode "pt>"
            ]
        ]))

renderHTMLRcdata :: Bool
renderHTMLRcdata =
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "title" [] [
            TextNode "<testing>/&+</&quot;>"
            ]
        ]))
    == "<title>&lt;testing>/&+&lt;/&amp;quot;></title>"

renderHTMLRcdataMult :: Bool
renderHTMLRcdataMult =
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "title" [] [
            TextNode "foo",
            TextNode "bar"
            ]
        ]))
    == "<title>foobar</title>"

renderHTMLRcdata2 :: Bool
renderHTMLRcdata2 = isBottom $
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "title" [] [
            Comment "foo"
            ]
        ]))

renderHTMLAmpAttr1 :: Bool
renderHTMLAmpAttr1 =
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "body" [("foo", "a & b")] [] ]))
    == "<body foo=\'a & b\'></body>"

renderHTMLAmpAttr2 :: Bool
renderHTMLAmpAttr2 =
    toByteString (render (HtmlDocument UTF8 Nothing [
        Element "body" [("foo", "a &amp; b")] [] ]))
    == "<body foo=\'a &amp;amp; b\'></body>"

