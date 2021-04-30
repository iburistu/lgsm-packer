package test

import (
	"flag"
	"testing"

	"github.com/gruntwork-io/terratest/modules/packer"
)

var game = flag.String("game", "", "Game server to launch")

func TestPackerDockerBuild(t *testing.T) {
	packerVars := map[string]string{
		"game": *game,
	}

	packerOptions := &packer.Options{
		Template: "../lgsm.pkr.hcl",
		Vars:     packerVars,
		Only:     "*docker",
	}

	packer.BuildArtifact(t, packerOptions)
}
