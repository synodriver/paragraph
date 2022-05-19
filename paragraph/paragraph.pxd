# cython: language_level=3
# cython: cdivision=True
from libc.stdint cimport int32_t
from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.map cimport map
from libcpp.functional cimport function

cdef extern from "include/core/SkCanvas.h" nogil:
    cppclass SkCanvas:
        pass

cdef extern from "include/core/SkScalar.h" nogil:
    ctypedef float SkScalar


cdef extern from "include/core/SkRect.h" nogil:
    struct SkRect:
        pass

cdef extern from "skia/tools/skqp/src/skqp.h" nogil:
    cppclass sk_sp[T]:
        pass
cdef extern from "include/core/SkFontMetrics.h" nogil:
    struct SkFontMetrics:
        pass
cdef extern from "include/core/SkString.h" nogil:
    cppclass SkString:
        SkString() except +

cdef extern from "include/core/SkPaint.h" nogil:
    cppclass SkPaint:
        SkPaint() except +

# ------------------------impl--------------------
cdef extern from "modules/skparagraph/include/TextStyle.h" namespace "skia::textlayout" nogil:
    cppclass TextStyle:
        pass

cdef extern from "modules/skparagraph/src/Run.h" namespace "skia::textlayout" nogil:
    cppclass Run:
        pass


cdef extern from "modules/skparagraph/src/TextLine.h" namespace "skia::textlayout" nogil:
    cppclass TextLine:
        struct ClipContext:
            const Run * run
            size_t pos
            size_t size
            SkScalar fTextShift  # Shifts the text inside the run so it's placed at the right position
            SkRect clip
            SkScalar fExcludedTrailingSpaces
            bool clippingNeeded

cdef extern from "modules/skparagraph/include/ParagraphStyle.h" namespace "skia::textlayout" nogil:
    struct ParagraphStyle:
        pass

cdef extern from "modules/skparagraph/include/FontCollection.h" namespace "skia::textlayout" nogil:
    cppclass FontCollection:
        pass

cdef extern from "modules/skparagraph/include/DartTypes.h" namespace "skia::textlayout" nogil:
    struct TextBox:
        pass
    cpdef enum class RectHeightStyle:
        pass
        # kTight
        # kMax
        # kIncludeLineSpacingMiddle
        # kIncludeLineSpacingTop
        # kIncludeLineSpacingBottom
        # kStrut

    cpdef enum class RectWidthStyle:
        pass

    cpdef enum class TextAlign:
        pass

    struct PositionWithAffinity:
        pass

    struct SkRange:
        pass


cdef extern from "modules/skparagraph/include/Metrics.h" namespace "skia::textlayout" nogil:
    cppclass StyleMetrics:
        StyleMetrics(const TextStyle* style) except +
        StyleMetrics(const TextStyle * style, SkFontMetrics& metrics) except +
        const TextStyle * text_style
        SkFontMetrics font_metrics

    cppclass LineMetrics:
        LineMetrics() except +
        LineMetrics(size_t start,
                size_t end,
                size_t end_excluding_whitespace,
                size_t end_including_newline,
                bool hard_break) except +
        size_t fStartIndex
        size_t fEndIndex
        size_t fEndExcludingWhitespaces
        size_t fEndIncludingNewline
        bool fHardBreak
        double fAscent
        double fDescent
        double fUnscaledAscent
        double fHeight
        double fWidth
        double fLeft
        double fBaseline
        size_t fLineNumber
        map[size_t, StyleMetrics] fLineMetrics

cdef extern from "modules/skparagraph/include/Paragraph.h" namespace "skia::textlayout" nogil:
    cppclass Paragraph:
        Paragraph(ParagraphStyle style, sk_sp[FontCollection] fonts) except +
        SkScalar getMaxWidth()
        SkScalar getHeight()
        SkScalar getMinIntrinsicWidth()
        SkScalar getMaxIntrinsicWidth()
        SkScalar getAlphabeticBaseline()
        SkScalar getIdeographicBaseline()
        SkScalar getLongestLine()
        bool didExceedMaxLines()
        void layout(SkScalar width)
        void paint(SkCanvas * canvas, SkScalar x, SkScalar y)
        vector[TextBox] getRectsForRange(unsigned start,
                                                  unsigned end,
                                                  RectHeightStyle rectHeightStyle,
                                                  RectWidthStyle rectWidthStyle)

        vector[TextBox] getRectsForPlaceholders()
        PositionWithAffinity getGlyphPositionAtCoordinate(SkScalar dx, SkScalar dy)
        SkRange[size_t] getWordBoundary(unsigned offset)
        void getLineMetrics(vector[LineMetrics] &)
        size_t lineNumber()
        void markDirty()
        int32_t unresolvedGlyphs()
        void updateTextAlign(TextAlign textAlign)
        void updateText(size_t from_, SkString text)
        void updateFontSize(size_t from_, size_t to, SkScalar fontSize)
        void updateForegroundPaint(size_t from_, size_t to, SkPaint paint)
        void updateBackgroundPaint(size_t from_, size_t to, SkPaint paint)
        enum VisitorFlags:
            pass
        struct VisitorInfo:
            pass
        Visitor = function[func]
        void visit(const Visitor &)
    ctypedef void (*func)(int lineNumber, const Paragraph.VisitorInfo *)

cdef extern from "Decorations.h" namespace "skia::textlayout" nogil:
    cppclass Decorations:
        void paint(SkCanvas * canvas, const TextStyle& textStyle, const TextLine.ClipContext& context,
                   SkScalar baseline)
