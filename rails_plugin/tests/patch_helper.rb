module GitPatchSnippets

  TWO_ADDS = %q{diff --git a/person.rb b/person.rb
new file mode 100644
--- /dev/null
+++ b/person.rb
@@ -0,0 +1,13 @@
+class Employee
+
+  attr_accessor :name, :age, :salary, :start_date, :tasks
+
+  def initialize(name, age, salary, start_date, tasks)
+    @name = name
+    @age = age
+    @salary = salary
+    @start_date = start_date
+    @tasks = tasks
+  end
+
+end
\ No newline at end of file
diff --git a/task.rb b/task.rb
new file mode 100644
--- /dev/null
+++ b/task.rb
@@ -0,0 +1,10 @@
+class Task
+
+  attr_accessor :name, :description
+
+  def initialize(name, description)
+    @name = name
+    @description = description
+  end
+
+end
\ No newline at end of file
}

  DELETE = %q{diff --git a/salary.rb b/salary.rb
deleted file mode 100644
--- a/salary.rb
+++ /dev/null
@@ -1,9 +0,0 @@
-class Salary
-
-  attr_reader :amount
-
-  def initialize(amount)
-    @amount = amount
-  end
-
-end
\ No newline at end of file
}

  RENAME_WITH_MODIFY = %q{diff --git a/task.rb b/todo.rb
rename from task.rb
rename to todo.rb
--- a/task.rb
+++ b/todo.rb
@@ -1,4 +1,4 @@
-class Task
+class Todo

   attr_accessor :name, :description

}

  FUNKY_PATHS = %q{diff --git a/foo/n o o b/b c a/README b/foo/n o o b/README.txt
rename from foo/n o o b/b c a/README
rename to foo/n o o b/README.txt

}

  MODIFY = %q{diff --git a/person.rb b/person.rb
--- a/person.rb
+++ b/person.rb
@@ -1,13 +1,13 @@
 class Employee

-  attr_accessor :name, :age, :salary, :start_date, :tasks
+  attr_accessor :name, :age, :salary, :start_date, :todos

-  def initialize(name, age, salary, start_date, tasks)
+  def initialize(name, age, salary, start_date, todos)
     @name = name
     @age = age
     @salary = salary
     @start_date = start_date
-    @tasks = tasks
+    @todos = todos
   end

 end
\ No newline at end of file}

  BINARY_ADD = <<-SNIPPET
diff --git a/image.png b/image.png
new file mode 100644
index 0000000000000000000000000000000000000000..9f0927f73e033a6b16f069a349cc608a72ce5174
GIT binary patch
literal 11168
zc$@*CD__(fiwFqJ7A8pm17mDyW@cYxVlH!WYyj<jdvofzvhUxlPeHA!eP`wlGYgyd
zn%Y$t2ua9FNFWIiYE@Bw1)Lb0!H_^c{b|W>Te4-aGjng<GqcYGTW<YY>Tb29mimuB
zzWnh=@y;-}i;Z$Wye`VZRuBbKDayOm8s2^Ra^HI>N}8(Z+qt4khOFv~;(v?3K;e1&
zzT5Br@)s^*ZUtQyHu79D^k-wUf?{)XyMh0hP~3Qawu(thMS7h-?{sOa8v0xWdI~D=
zENG_km%lQgFkdOADJ*b-cVVLgF{_ATO2S&P>Cf#~PBjQMFf|ZX%J<@Z_p*1>F0OZ?
zrb>Sm9}a7H*uA~E=?xzKD&7N}mGHgz$6v+UcU{@QUzlgRK=F1EBv9<%1LroU&NCAe}
  SNIPPET

  BINARY_MODIFY = <<-SNIPPET
diff --git a/image.png b/image.png
index 9f0927f73e033a6b16f069a349cc608a72ce5174..b0349fd40a279047c70a0b1fcbd74f5cd8a44d6b
GIT binary patch
literal 247052
zc$^ehV_2na5I!f{wz=_S+qT`wt__=Ao2|{p?uO0gR;SI_YO`(Q>-+V-*E4g?%rm&>
zerVOCWLP*@K}fWNyH~r%71xDRgTqK%6zmi(7WPO&LKJLD*3LGbwiMhSM;a7tGIoxh
z*6tr)M{`eWDQim?D{Bf75hM>!cWZMeBp+Z?*J(qotlRlx*N<XRNK6v-)Ru41r4%F_
z1IiO6<&#sd$o6A!3oUX|czo}YhbXoi>%P&<<Lj~S@vruV_V+IQ&r2uTo;EhtVC&s4
zug{O?lkb7wE3Thk*423T-JJgfy<EK<UwiM92R;M@1U|pEiRh}HLf*CJ+XRB%?^Y)#
  SNIPPET

  BINARY_DELETE = <<-SNIPPET
diff --git a/image.png b/image.png
deleted file mode 100644
Binary file image.png has changed

  SNIPPET

  BINARY_RENAME_WITH_MODIFY = <<-SNIPPET
diff --git a/image.png b/picture.png
rename from image.png
rename to picture.png
index 5008ddfcf53c02e82d7eee2e57c38e5672ef89f6..b0349fd40a279047c70a0b1fcbd74f5cd8a44d6b
GIT binary patch
literal 247052
zc$^ehV_2na5I!f{wz=_S+qT`wt__=Ao2|{p?uO0gR;SI_YO`(Q>-+V-*E4g?%rm&>
zerVOCWLP*@K}fWNyH~r%71xDRgTqK%6zmi(7WPO&LKJLD*3LGbwiMhSM;a7tGIoxh
z*6tr)M{`eWDQim?D{Bf75hM>!cWZMeBp+Z?*J(qotlRlx*N<XRNK6v-)Ru41r4%F_
z1IiO6<&#sd$o6A!3oUX|czo}YhbXoi>%P&<<Lj~S@vruV_V+IQ&r2uTo;EhtVC&s4
zug{O?lkb7wE3Thk*423T-JJgfy<EK<UwiM92R;M@1U|pEiRh}HLf*CJ+XRB%?^Y)#
zW`)pieQSrWTlP(Yl(mCq3f518@}t0hM@QfPd`F$voTPuM2>kxAd!s8X694+>^mNRn
  SNIPPET

  COPY = <<-SNIPPET
diff --git a/trunk/README b/tags/thought_viscera-3.6/README
copy from trunk/README
copy to tags/thought_viscera-3.6/README
diff --git a/trunk/Rakefile b/tags/thought_viscera-3.6/Rakefile
copy from trunk/Rakefile
copy to tags/thought_viscera-3.6/Rakefile
  SNIPPET

end