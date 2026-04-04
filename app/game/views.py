from django.shortcuts import render

# Create your views here.
def game_list(request):
    #returns the calculator page
    result = {}
    try:
        if request.method == "POST":
            n1 = eval(request.POST['num1'])
            n2 = eval(request.POST['num2'])
            opr = request.POST['opr']
            match opr:
                case '+':
                    output = n1 + n2
                case '-':
                    output = n1 - n2
                case '*':
                    output = n1 * n2
                case '/':
                    output = n1 / n2
                case _:
                    output = n1 + n2

            result = {
                'output': output,
                'num1': n1,
                'num2': n2
            }

            return render(request, 'game/game_index.html', result)
        
    except:
        output = "Invalid Operation"
    
    return render(request, 'game/game_index.html')