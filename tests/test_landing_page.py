import re
import unittest
from html.parser import HTMLParser
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HTML = (ROOT / "index.html").read_text(encoding="utf-8")
CSS = (ROOT / "assets" / "landing.css").read_text(encoding="utf-8")


class LandingParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids = []
        self.links = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if "id" in attrs:
            self.ids.append(attrs["id"])
        if tag == "a":
            self.links.append(attrs.get("href", ""))


class LandingPageTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.parser = LandingParser()
        cls.parser.feed(HTML)

    def test_story_sections_exist_in_decision_order(self):
        expected = ["why-now", "problem", "solution", "how-it-works", "why-runway", "pricing"]
        positions = [HTML.index(f'id="{section}"') for section in expected]
        self.assertEqual(positions, sorted(positions))

    def test_pending_review_is_honest_and_cta_scrolls_on_page(self):
        self.assertIn("Coming soon to the App Store", HTML)
        self.assertIn('href="#how-it-works"', HTML)
        self.assertNotRegex(HTML, r'href="[^"]*apps\.apple\.com')

    def test_page_tells_the_study_story_without_outline_labels(self):
        for phrase in (
            "two years abroad",
            "The spreadsheet gave me an answer",
            "So I built Runway",
            "It stays simple enough to trust",
        ):
            self.assertIn(phrase, HTML)
        for internal_label in (
            "Why people come",
            "The problem",
            "The answer",
            "How it works",
            "Why this app",
            "Simple on purpose",
            "Why I built it",
        ):
            self.assertNotIn(f'<p class="eyebrow">{internal_label}', HTML)

    def test_real_product_images_and_accessible_motion_are_preserved(self):
        for image in ("01-runway.png", "02-living.png", "03-log.png", "04-plan.png"):
            self.assertIn(f"assets/device/{image}", HTML)
        self.assertIn("prefers-reduced-motion: reduce", CSS)

    def test_mobile_layout_has_a_deliberate_breakpoint(self):
        self.assertRegex(CSS, r"@media\s*\(max-width:\s*48rem\)")

    def test_opaque_icon_is_clipped_inside_a_separate_glow_frame(self):
        self.assertIn('class="app-mark"', HTML)
        self.assertIn('class="app-mark app-mark-large"', HTML)
        self.assertRegex(CSS, r"\.app-mark\s+img\s*\{[^}]*clip-path:\s*inset\((?!0(?:px|%|\s))")


if __name__ == "__main__":
    unittest.main()
