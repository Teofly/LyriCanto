//
//  MetricsValidatorTests.swift
//  LyriCanto Tests
//
//  Unit tests for MetricsValidator
//

import XCTest
@testable import LyriCanto

final class MetricsValidatorTests: XCTestCase {
    
    var validator: MetricsValidator!
    
    override func setUp() {
        super.setUp()
        validator = MetricsValidator()
    }
    
    override func tearDown() {
        validator = nil
        super.tearDown()
    }
    
    // MARK: - Syllable Counting Tests
    
    func testItalianSyllableCount() {
        XCTAssertEqual(validator.countSyllables("ciao", language: "IT"), 2)
        XCTAssertEqual(validator.countSyllables("casa", language: "IT"), 2)
        XCTAssertEqual(validator.countSyllables("amore", language: "IT"), 3)
        XCTAssertEqual(validator.countSyllables("felicità", language: "IT"), 4)
        XCTAssertEqual(validator.countSyllables("meraviglioso", language: "IT"), 5)
    }
    
    func testEnglishSyllableCount() {
        XCTAssertEqual(validator.countSyllables("cat", language: "EN"), 1)
        XCTAssertEqual(validator.countSyllables("hello", language: "EN"), 2)
        XCTAssertEqual(validator.countSyllables("beautiful", language: "EN"), 3)
        XCTAssertEqual(validator.countSyllables("education", language: "EN"), 4)
    }
    
    func testSilentERule() {
        // Test silent 'e' at end
        XCTAssertEqual(validator.countSyllables("make", language: "EN"), 1)
        XCTAssertEqual(validator.countSyllables("time", language: "EN"), 1)
        XCTAssertEqual(validator.countSyllables("love", language: "EN"), 1)
    }
    
    func testSpanishSyllableCount() {
        XCTAssertEqual(validator.countSyllables("hola", language: "ES"), 2)
        XCTAssertEqual(validator.countSyllables("amor", language: "ES"), 2)
        XCTAssertEqual(validator.countSyllables("música", language: "ES"), 3)
    }
    
    func testEmptyString() {
        XCTAssertEqual(validator.countSyllables("", language: "IT"), 1)
    }
    
    func testPunctuationRemoval() {
        XCTAssertEqual(
            validator.countSyllables("Hello, world!", language: "EN"),
            validator.countSyllables("Hello world", language: "EN")
        )
    }
    
    // MARK: - Metrics Analysis Tests
    
    func testBasicAnalysis() {
        let text = """
        Nel blu dipinto di blu
        Felice di stare quassù
        E volavo volavo felice
        Più in alto del sole
        """
        
        let analysis = validator.analyzeText(text, language: "IT", sections: [])
        
        XCTAssertEqual(analysis.totalLines, 4)
        XCTAssertTrue(analysis.averageSyllables > 0)
        XCTAssertEqual(analysis.syllableCounts.count, 4)
    }
    
    func testEmptyTextAnalysis() {
        let analysis = validator.analyzeText("", language: "IT", sections: [])
        
        XCTAssertEqual(analysis.totalLines, 0)
        XCTAssertEqual(analysis.syllableCounts.count, 0)
        XCTAssertTrue(analysis.warnings.contains("Nessuna riga da analizzare"))
    }
    
    func testHighVarianceWarning() {
        let text = """
        Hi
        This is a very long line with many syllables
        Ok
        Another extremely long line that goes on and on
        """
        
        let analysis = validator.analyzeText(text, language: "EN", sections: [])
        
        let hasVarianceWarning = analysis.warnings.contains { warning in
            warning.contains("Alta varianza")
        }
        XCTAssertTrue(hasVarianceWarning)
    }
    
    // MARK: - Comparison Tests
    
    func testPerfectMetricMatch() {
        let original = """
        Line one here
        Line two here
        Line three here
        """
        
        let generated = """
        Same count here
        Same count here
        Same count here
        """
        
        let originalAnalysis = validator.analyzeText(original, language: "EN", sections: [])
        let generatedAnalysis = validator.analyzeText(generated, language: "EN", sections: [])
        
        let score = validator.compareMetrics(
            original: originalAnalysis,
            generated: generatedAnalysis
        )
        
        XCTAssertGreaterThanOrEqual(score, 0.85, "Perfect match should score >= 0.85")
    }
    
    func testPoorMetricMatch() {
        let original = """
        Hi
        Hello
        Hey
        """
        
        let generated = """
        This is a very long line
        Another long line here
        And yet another one
        """
        
        let originalAnalysis = validator.analyzeText(original, language: "EN", sections: [])
        let generatedAnalysis = validator.analyzeText(generated, language: "EN", sections: [])
        
        let score = validator.compareMetrics(
            original: originalAnalysis,
            generated: generatedAnalysis
        )
        
        XCTAssertLessThan(score, 0.5, "Poor match should score < 0.5")
    }
    
    func testDifferentLineCounts() {
        let original = """
        Line one
        Line two
        """
        
        let generated = """
        Line one
        Line two
        Line three
        """
        
        let originalAnalysis = validator.analyzeText(original, language: "EN", sections: [])
        let generatedAnalysis = validator.analyzeText(generated, language: "EN", sections: [])
        
        let score = validator.compareMetrics(
            original: originalAnalysis,
            generated: generatedAnalysis
        )
        
        XCTAssertEqual(score, 0.0, "Different line counts should return 0")
    }
    
    // MARK: - Token Estimation Tests
    
    func testTokenEstimation() {
        let shortText = "Hello world"
        let tokens = validator.estimateTokenCount(shortText)
        
        XCTAssertGreaterThan(tokens, 0)
        XCTAssertLessThanOrEqual(tokens, 10)
    }
    
    func testLongerTokenEstimation() {
        let longText = String(repeating: "word ", count: 100)
        let tokens = validator.estimateTokenCount(longText)
        
        XCTAssertGreaterThan(tokens, 50)
    }
    
    // MARK: - Rhyme Detection Tests
    
    func testSimpleRhymeDetection() {
        let text = """
        Roses are red
        Violets are blue
        Sugar is sweet
        And so are you
        """
        
        let analysis = validator.analyzeText(text, language: "EN", sections: [])
        
        XCTAssertNotNil(analysis.rhymeScheme)
        // Expected: ABCB or similar
    }
    
    // MARK: - Warning Generation Tests
    
    func testLongLineWarning() {
        let text = "This is an extremely long line with way too many syllables for any reasonable song"
        
        let analysis = validator.analyzeText(text, language: "EN", sections: [])
        
        let hasLongLineWarning = analysis.warnings.contains { warning in
            warning.contains("molto lunga")
        }
        XCTAssertTrue(hasLongLineWarning)
    }
    
    func testShortLineWarning() {
        let text = "Hi"
        
        let analysis = validator.analyzeText(text, language: "EN", sections: [])
        
        let hasShortLineWarning = analysis.warnings.contains { warning in
            warning.contains("molto corta")
        }
        XCTAssertTrue(hasShortLineWarning)
    }
    
    // MARK: - Integration Tests
    
    func testRealWorldExample() {
        let original = """
        Nel blu dipinto di blu
        Felice di stare quassù
        E volavo volavo felice
        Più in alto del sole ed ancora più su
        """
        
        let generated = """
        Nel web connesso in 5G
        Navigo veloce da qui
        Scarico e carico felice
        Più veloce del bit e ancora di più
        """
        
        let originalAnalysis = validator.analyzeText(original, language: "IT", sections: [])
        let generatedAnalysis = validator.analyzeText(generated, language: "IT", sections: [])
        
        let score = validator.compareMetrics(
            original: originalAnalysis,
            generated: generatedAnalysis
        )
        
        // Should have good compatibility
        XCTAssertGreaterThanOrEqual(score, 0.7)
        
        // Check report generation doesn't crash
        let report = originalAnalysis.generateReport()
        XCTAssertFalse(report.isEmpty)
        XCTAssertTrue(report.contains("ANALISI METRICA"))
    }
}

// MARK: - Phonetic Similarity Tests

final class PhoneticHelperTests: XCTestCase {
    
    func testPhoneticSimilarity() {
        let similarity1 = PhoneticHelper.calculatePhoneticSimilarity("cat", "bat")
        let similarity2 = PhoneticHelper.calculatePhoneticSimilarity("cat", "xyz")
        
        XCTAssertGreaterThan(similarity1, similarity2)
    }
    
    func testPhoneticFeatures() {
        let features = PhoneticHelper.getPhoneticFeatures("hello")
        
        XCTAssertFalse(features.isEmpty)
        XCTAssertTrue(features.contains("V")) // vowel
        XCTAssertTrue(features.contains("C")) // consonant
    }
}
