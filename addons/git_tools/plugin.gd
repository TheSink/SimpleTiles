tool
extends EditorPlugin

var output = ["none"]


func _enter_tree():
	add_tool_menu_item("[Git] Pull From Repo", self, "pull")
	add_tool_menu_item("[Git] Push To Repo", self, "push")


func _exit_tree():
	remove_tool_menu_item("[Git] Pull From Repo")
	remove_tool_menu_item("[Git] Push To Repo")

func pull(_arg):
	output = []
	OS.execute("git", ["pull"], true, output)
	output_log()

func push(_arg):
	output = []
	OS.execute("git", ["push"], true, output)
	output_log()
	
func output_log():
	var string = ""
	for element in output:
		string += element + "\n"
	print(string)
