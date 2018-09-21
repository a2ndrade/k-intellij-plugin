package com.appian.intellij.k;

import java.util.Map;

import javax.swing.Icon;

import com.intellij.openapi.editor.colors.TextAttributesKey;
import com.intellij.openapi.fileTypes.SyntaxHighlighter;
import com.intellij.openapi.options.colors.AttributesDescriptor;
import com.intellij.openapi.options.colors.ColorDescriptor;
import com.intellij.openapi.options.colors.ColorSettingsPage;

public final class KColorSettingsPage implements ColorSettingsPage {

  private static final AttributesDescriptor[] DESCRIPTORS = new AttributesDescriptor[]{
    new AttributesDescriptor("Number", KSyntaxHighlighter.NUMBER),
    new AttributesDescriptor("Number Vector", KSyntaxHighlighter.NUMBER_VECTOR),
    new AttributesDescriptor("Char", KSyntaxHighlighter.CHAR),
    new AttributesDescriptor("String", KSyntaxHighlighter.STRING),
    new AttributesDescriptor("Symbol", KSyntaxHighlighter.SYMBOL),
    new AttributesDescriptor("Symbol Vector", KSyntaxHighlighter.SYMBOL_VECTOR),
    new AttributesDescriptor("Operator", KSyntaxHighlighter.OPERATOR),
    new AttributesDescriptor("Identifier", KSyntaxHighlighter.IDENTIFIER),
    new AttributesDescriptor("SysFunction", KSyntaxHighlighter.IDENTIFIER_SYS),
    new AttributesDescriptor("Adverb", KSyntaxHighlighter.ADVERB),
    new AttributesDescriptor("Keyword", KSyntaxHighlighter.KEYWORD),
    new AttributesDescriptor("Command", KSyntaxHighlighter.COMMAND)
  };

  @Override
  public Icon getIcon() {
    return KIcons.FILE;
  }

  @Override
  public SyntaxHighlighter getHighlighter() {
    return new KSyntaxHighlighter();
  }

  @Override
  public String getDemoText() {
    return "3.5\n" +
      "1 2 2.4 0N 3 43 0i / numbers\n" +
      "\"c\"\n" +
      "\"string\"\n" +
      "`symbol\n" +
      "`a`b`c\n" +
      "identifier\n" +
      "(+;*;<;>;~=)\n" +
      "count\n" +
      "a ,/:\\\\: b\n" +
      "(if[];?[];$[])\n" +
      "\\d .some.dir";
  }

  @Override
  public Map<String,TextAttributesKey> getAdditionalHighlightingTagToDescriptorMap() {
    return null;
  }

  @Override
  public AttributesDescriptor[] getAttributeDescriptors() {
    return DESCRIPTORS;
  }

  @Override
  public ColorDescriptor[] getColorDescriptors() {
    return ColorDescriptor.EMPTY_ARRAY;
  }

  @Override
  public String getDisplayName() {
    return "q";
  }
}
