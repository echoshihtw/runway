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

    def test_life_chapter_line_is_inclusive_not_segmented(self):
        self.assertIn(
            "For studying, changing direction, building something, or taking an adventure.",
            HTML,
        )
        self.assertNotIn('class="trigger-list"', HTML)

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

    def test_runway_result_uses_an_app_card_not_a_circle(self):
        self.assertIn('class="status-badge"', HTML)
        runway_rule = re.search(r"\.runway-answer\s*\{([^}]*)\}", CSS)
        self.assertIsNotNone(runway_rule)
        self.assertNotIn("border-radius:50%", runway_rule.group(1).replace(" ", ""))

    def test_editorial_redesign_uses_layered_shape_language(self):
        for class_name in (
            "hero-field",
            "hero-shape",
            "life-transition",
            "cut-shape",
            "story-field",
            "story-shape",
        ):
            self.assertIn(f'class="{class_name}', HTML)

    def test_life_moments_are_an_editorial_transition_not_category_cards(self):
        self.assertIn("When life changes shape, money becomes time.", HTML)
        self.assertIn("A study plan, a new direction, something you are building", HTML)
        self.assertIn('class="life-transition"', HTML)
        self.assertIn('class="cut-shape cut-leaf"', HTML)
        self.assertIn('class="cut-shape cut-star"', HTML)
        self.assertNotIn('class="problem-grid"', HTML)
        self.assertNotIn('class="chapter-card"', HTML)

    def test_redesign_keeps_real_product_screens_as_the_visual_proof(self):
        hero_field = HTML[HTML.index('class="hero-field"'):HTML.index('</section>', HTML.index('class="hero-field"'))]
        self.assertIn("assets/device/01-runway.png", hero_field)
        self.assertRegex(CSS, r"\.hero-field\s*\{[^}]*overflow:\s*hidden")

    def test_navigation_floats_above_the_page_while_scrolling(self):
        header_rules = re.findall(r"\.landing header\.site\s*\{([^}]*)\}", CSS)
        self.assertTrue(header_rules)
        combined = "".join(header_rules).replace(" ", "")
        self.assertIn("position:sticky", combined)
        self.assertRegex(combined, r"top:[^;]+")
        self.assertIn("background:transparent", combined)
        self.assertIn("header.site.is-scrolled", CSS)
        self.assertIn("background:rgba(242,239,231,.72)", CSS.replace(" ", ""))
        self.assertIn("backdrop-filter:blur(22px)", CSS.replace(" ", ""))
        self.assertIn("window.scrollY", HTML)
        self.assertIn("is-scrolled", HTML)
        self.assertIn("header.site:not(.is-scrolled)", CSS)
        self.assertIn("color:#f3f5fa", CSS.replace(" ", ""))

    def test_large_one_corner_radius_is_not_repeated_across_surfaces(self):
        for repeated_shape in (
            "border-radius:1rem 2.8rem 1rem 1rem",
            "border-radius:1.4rem 4.6rem 1.4rem 1.4rem",
            "border-radius:1.7rem 4rem 1.7rem 1.7rem",
            "border-radius:1.4rem 4.5rem 1.4rem 1.4rem",
        ):
            self.assertNotIn(repeated_shape, CSS)


if __name__ == "__main__":
    unittest.main()
