#include<cstdlib>
#include<cstdio>
#include<cstring>
//using namespace std;
int main(int argc, char *argv[])
{
    if (argc==1)
    {
        puts("ERROR: Please input the file name!");
        return 0;
    }
    char s1[100]="masm ";
    char s2[100]="link ";
    char q[100];
    strcpy(q,argv[1]);
    for (int i=0; q[i]; i++)
    {
        if (q[i]=='\\')
            q[i]='/';
        if (q[i]==' ')
        {
            puts("ERROR: MASM can not handle paths with spaces!");
            return 0;
        }
    }
    char *s;
    int x;
    for (x=strlen(q)-1;x>=0;x--)
        if (q[x]=='/')
            break;
    s=q+x+1;
    int l=strlen(s);
    if (l>4&&s[l-1]=='m'&&s[l-2]=='s'&&s[l-3]=='a'&&s[l-4]=='.')
    {
//        strcat(s1,"\"");
        strcat(s1,q);
//        strcat(s1,"\"");
        strncat(s2,s,l-4);
        strcat(s2,".obj,,nul,,,");
    }
    else
    {
        puts("ERROR: Please input the correct file name!");
        return 0;
    }
    system("link ,,");
    system("cls");
//    puts(s1);
    system(s1);
    puts("==========End Compilation==========");
//    puts(s2);
    system(s2);
    puts("=============End  Link=============");
    return 0;
}
