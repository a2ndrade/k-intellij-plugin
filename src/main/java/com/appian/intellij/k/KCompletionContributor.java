package com.appian.intellij.k;

import java.util.Arrays;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Stream;

import org.jetbrains.annotations.NotNull;

import com.appian.intellij.k.psi.KAssignment;
import com.appian.intellij.k.psi.KLambda;
import com.appian.intellij.k.psi.KTypes;
import com.appian.intellij.k.psi.KUserId;
import com.intellij.codeInsight.completion.CompletionContributor;
import com.intellij.codeInsight.completion.CompletionParameters;
import com.intellij.codeInsight.completion.CompletionProvider;
import com.intellij.codeInsight.completion.CompletionResultSet;
import com.intellij.codeInsight.completion.CompletionType;
import com.intellij.codeInsight.lookup.LookupElementBuilder;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.vfs.VirtualFile;
import com.intellij.patterns.PlatformPatterns;
import com.intellij.psi.PsiElement;
import com.intellij.psi.search.FileTypeIndex;
import com.intellij.psi.search.GlobalSearchScope;
import com.intellij.psi.util.PsiTreeUtil;
import com.intellij.util.ProcessingContext;

public class KCompletionContributor extends CompletionContributor {

  static final String[] SYSTEM_FNS_Q = new String[] {"abs", "acos", "aj", "aj0", "all", "and", "any", "asc",
      "asin", "asof", "atan", "attr", "avg", "avgs", "bin", "binr", "by", "ceiling", "cols", "cor", "cos",
      "count", "cov", "cross", "csv", "cut", "delete", "deltas", "desc", "dev", "differ", "distinct", "div",
      "dsave", "each", "ej", "ema", "enlist", "eval", "except", "exec", "exit", "exp", "fby", "fills",
      "first", "fkeys", "flip", "floor", "from", "get", "getenv", "group", "gtime", "hclose", "hcount",
      "hdel", "hopen", "hsym", "iasc", "idesc", "ij", "in", "insert", "inter", "inv", "key", "keys", "last",
      "like", "lj", "ljf", "load", "log", "lower", "lsq", "ltime", "ltrim", "mavg", "max", "maxs", "mcount",
      "md5", "mdev", "med", "meta", "min", "mins", "mmax", "mmin", "mmu", "mod", "msum", "neg", "next", "not",
      "null", "or", "over", "parse", "peach", "pj", "prd", "prds", "prev", "prior", "rand", "rank", "ratios",
      "raze", "read0", "read1", "reciprocal", "reverse", "rload", "rotate", "rsave", "rtrim", "save", "scan",
      "scov", "sdev", "select", "set", "setenv", "show", "signum", "sin", "sqrt", "ss", "ssr", "string",
      "sublist", "sum", "sums", "sv", "svar", "system", "tables", "tan", "til", "trim", "type", "uj",
      "ungroup", "union", "update", "upper", "upsert", "value", "var", "view", "views", "vs", "wavg", "where",
      "within", "wj", "wj1", "wsum", "ww", "xasc", "xbar", "xcol", "xcols", "xdesc", "xexp", "xgroup", "xkey",
      "xlog", "xprev", "xrank"};

  static {
    Arrays.sort(SYSTEM_FNS_Q);
  }

  public static boolean isSystemFn(String fnName) {
    if (Arrays.binarySearch(SYSTEM_FNS_Q, fnName) >= 0) {
      return true;
    }
    if (fnName.startsWith(".z.")) {
      return true;
    }
    return false;
  }

  public KCompletionContributor() {
    extend(CompletionType.BASIC,
        PlatformPatterns.psiElement(KTypes.USER_IDENTIFIER).withLanguage(KLanguage.INSTANCE),
        new CompletionProvider<CompletionParameters>() {
          public void addCompletions(@NotNull CompletionParameters parameters, ProcessingContext context, @NotNull CompletionResultSet resultSet) {
            final CompletionResultSet caseInsensitiveResultSet = resultSet.caseInsensitive();
            final PsiElement element = parameters.getOriginalPosition();
            if (element == null) {
              return;
            }
            final String input = element.getText() == null ? "" : element.getText();
            final KLambda enclosingLambda = PsiTreeUtil.getContextOfType(element, KLambda.class);
            // system functions
            contributeSystemFunctions(resultSet, input);
            // params
            final Map<String,KUserId> uniques = new LinkedHashMap<>();
            Optional.ofNullable(enclosingLambda)
                .map(KLambda::getLambdaParams)
                .map(params -> params.getUserIdList()
                    .stream()
                    .filter(param -> param.getName().contains(input)))
                .orElse(Stream.empty())
                .forEach(param -> uniques.putIfAbsent(param.getName(), param));
            // locals
            Optional.ofNullable(PsiTreeUtil.findChildrenOfType(enclosingLambda, KAssignment.class).stream()
                .map(KAssignment::getUserId)
                .filter(id -> id.getName().contains(input)))
                .orElse(Stream.empty())
                .forEach(local -> uniques.putIfAbsent(local.getName(), local));
            for (KUserId local : uniques.values()) {
              caseInsensitiveResultSet.addElement(LookupElementBuilder.create(local));
            }
            // globals (same file)
            final Project project = element.getProject();
            final VirtualFile sameFile = element.getContainingFile().getVirtualFile();
            Optional.ofNullable(KUtil.findIdentifiers(project, sameFile).stream()
                .filter(id -> id.getName().contains(input)))
                .orElse(Stream.empty())
                .forEach(global -> caseInsensitiveResultSet.addElement(LookupElementBuilder.create(global)));
            // globals (other files)
            if (caseInsensitiveResultSet.isStopped()) {
              return;
            }
            final String sameFilePath = sameFile.getCanonicalPath();
            final KUserIdCache cache = KUserIdCache.getInstance();
            final Collection<VirtualFile> otherFiles = FileTypeIndex.getFiles(KFileType.INSTANCE,
                GlobalSearchScope.allScope(project));
            for (VirtualFile otherFile : otherFiles) {
              if (sameFilePath.equals(otherFile.getCanonicalPath())) {
                continue; // already processed above
              }
              Optional.ofNullable(cache.findAllIdentifiers(project, otherFile, input, new KUtil.PrefixMatcher(input)).stream())
                  .orElse(Stream.empty())
                  .forEach(global -> {
                    final String fqn = KUtil.getFqn(global);
                    final LookupElementBuilder lookup = fqn == null ?
                        LookupElementBuilder.create(global) :
                        LookupElementBuilder.create(global, fqn);
                    caseInsensitiveResultSet.addElement(lookup);
                  });
            }
          }
        }
    );
  }

  private void contributeSystemFunctions(CompletionResultSet resultSet, String input) {
    if (input.charAt(0) == '.') {
     return; // ignore for completion b/c real declarations are in q.k or in app code as handle fns
    }
    int i = Math.abs(Arrays.binarySearch(SYSTEM_FNS_Q, input) + 1);
    while (i < SYSTEM_FNS_Q.length && SYSTEM_FNS_Q[i].startsWith(input)) {
      resultSet.addElement(LookupElementBuilder.create(SYSTEM_FNS_Q[i++]));
    }
  }

}
