import 'package:guardian/utils/junit_xml/junit_xml.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../test_utils/xml_string_parse_util.dart';

void main() {
  group('XmlElementParser', () {
    XmlElement xmlElement;

    setUpAll(() {
      const xml = '''
        <?xml version='1.0' encoding='UTF-8'?>
        <stubs count="2" type="random">
          <stub name="var1" value="1"/>
          <stub name="var2" value="two"/>
        </stubs>
      ''';
      xmlElement = XmlStringParseUtil.parseXml(xml);
    });

    test(
      'getAttributes() should return map with attributes names and values',
      () {
        final parserStub = XmlElementParserTestbed();
        const expected = {
          'count': '2',
          'type': 'random',
        };

        final result = parserStub.getAttributes(xmlElement);

        expect(result, equals(expected));
      },
    );

    test(
      'checkAttributes() should return false if attribute is not presented',
      () {
        final parserStub = XmlElementParserTestbed();
        final attributes = {
          'name': StringAttributeValueParser(),
        };

        final result = parserStub.checkAttributes(xmlElement, attributes);

        expect(result, isFalse);
      },
    );

    test(
      'checkAttributes() should return false if cannot parse attribute',
      () {
        final parserStub = XmlElementParserTestbed();
        final attributes = {
          'type': IntAttributeValueParser(),
        };

        final result = parserStub.checkAttributes(xmlElement, attributes);

        expect(result, isFalse);
      },
    );

    test(
      'countChildren() should count nested nodes with name specified in parser',
      () {
        final parserStub = XmlElementParserTestbed('stub');

        final result = parserStub.countChildren(parserStub, xmlElement);

        expect(result, equals(2));
      },
    );

    test('validate() should return true by default', () {
      final parserStub = XmlElementParserTestbed();

      final result = parserStub.validate(xmlElement);

      expect(result, isTrue);
    });

    test(
      'parseChildren() should parse nested nodes with name specified in parser',
      () {
        final parserStub = XmlElementParserTestbed('stub');

        final result = parserStub.parseChildren(parserStub, xmlElement);

        expect(result, hasLength(2));
      },
    );

    test(
      'parseChild() should should throw StateError if there are more than '
      'one nested node matching given name',
      () {
        final parserStub = XmlElementParserTestbed('stub');

        expect(
          () => parserStub.parseChild(parserStub, xmlElement),
          throwsStateError,
        );
      },
    );

    test(
      'parseChild() should parse single nested node '
      'with name specified in parser',
      () {
        const xml = '''
          <?xml version='1.0' encoding='UTF-8'?>
          <stubs count="2" type="random">
            <stub name="var1" value="1"/>
          </stubs>
        ''';
        final xmlElement = XmlStringParseUtil.parseXml(xml);
        final parserStub = XmlElementParserTestbed('stub');

        final result = parserStub.parseChild(parserStub, xmlElement);

        expect(result, isNotNull);
      },
    );

    test(
      'parse() should throw ArgumentError if '
      'parser name does not match element name',
      () {
        final parserStub = XmlElementParserTestbed('random');

        expect(() => parserStub.parse(xmlElement), throwsArgumentError);
      },
    );

    test(
      'parse() should throw FormatException if failed to validate element',
      () {
        final parserStub = AlwaysInvalidXmlElementParserTestbed('stubs');

        expect(
          () => parserStub.parse(xmlElement),
          throwsFormatException,
        );
      },
    );

    test(
      'parse() should parse element',
      () {
        final parserStub = XmlElementParserTestbed('stubs');

        final result = parserStub.parse(xmlElement);

        expect(result, isNotNull);
      },
    );
  });
}

/// A testbed class for abstract [XmlElementParser] with mock for [elementName].
/// Allows to test [nonVirtual] methods of element parser.
class XmlElementParserTestbed extends XmlElementParser<bool> {
  final String _elementName;

  XmlElementParserTestbed([this._elementName]);

  @override
  String get elementName => _elementName;

  @override
  bool mapElement(XmlElement xmlElement) {
    return true;
  }
}

/// A testbed class for abstract [XmlElementParser] that always returns
/// false on validate.
class AlwaysInvalidXmlElementParserTestbed extends XmlElementParserTestbed {
  AlwaysInvalidXmlElementParserTestbed([String elementName])
      : super(elementName);

  @override
  bool validate(XmlElement xmlElement) {
    return false;
  }
}
